function [fout hpy sclv] = growsys(op,ends,pref)
% G = CHEBSYS(F,ENDS) or G = CHEBSYS(F,ENDS,PRED) or 
% A simple chebfun constructor for systems. 
%
% Example 
%     myfun = @(x) { sin( length(x{2})*x{1} ), cos(10*x{2}) };
%     ends = {[-1 1],[-1 1]};
%     f = chebsys(myfun, ends);
%     f{1},f{2}
%     plot(f{1},'b',f{2},'r','linewidth',2)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Written by RodP, updated by NicH 07/2010

% % NOTES
% use autosys for splitting (bisection only).
% Should allow different minsamples, max degees for each fun.
% Currently only supports linear maps.
% If the systems are independent, ~pref.resampling will prevent re-evaluation 
% of converged cells. (Currently disabled).

if nargin < 3, pref = chebfunpref; end         

% -------------------------------------------------------------------------
% ERROR TRAPPING. NEEDS DOING PROPERLY.
if pref.chebkind~=2
    error('CHEBFUN:chebsys:kind','chebsys only supports 2nd-kind points');
end
if pref.sampletest, 
%     warning('Sampletest not supported in chebsys.'); 
    pref.sampletest = 0;
end
if ~pref.resampling
%     warning('resampling ''off'' is not supported in chebsys.'); 
    pref.resampling = 1;
end
if isfield(pref,'exps') && any(pref.exps)
    pref.exps
    warning('CHEBFUN:chebsys:exp','Exps not supported in chebsys.'); 
end
% -------------------------------------------------------------------------

% Force the size of the system (for linops)
if isfield(pref,'syssize') && ~isempty(pref.syssize)
    syssize = pref.syssize;
    if ~iscell(ends)
        if isa(ends,'domain')
            ends = ends.endsandbreaks;
        end
        ends = repmat({ends},syssize);
    end
%     if ~iscell(op)
%         op = @(x) repmat({op(x)},syssize);
%     end
end   

% Determine the size of the system and number of intervals
syssize = numel(ends);
numints = numel([ends{:}]) - syssize;

bks = zeros(syssize,1);
oldends = ends; ends = zeros(numints,2);
l = 1;
for j = 1:syssize
    bks(j) = numel(oldends{j})-1;
    for k = 1:bks(j)
        ends(l,:) = oldends{j}(k:k+1);
        l = l+1;
    end
end

if diff(ends,[],2) < 0
    error('CHEBFUN:chebsys:vecends','Vector of endpoints should have increasing values.')
end

% Set minn (minimum number of samples)
minn = pref.minsamples;
minpower = max(1,ceil(log2(minn-1)));

% Set maxn (the maximum length we'll allow)
if pref.splitting
    maxn = pref.splitdegree + 1;
else
    maxn = pref.maxdegree + 1;
end
maxpower = max(minpower,floor(log2(maxn-1)));

% We take integer powers up to 2^6 (=64), then integer and half-interger
% powers (i.e. 2^6.5, 2^7, 2^7.5, ...) up to 2^maxpower.
npn = max(min(maxpower,6),minpower);
kk = 1 + round(2.^[ (minpower:npn) (2*npn+1:2*maxpower)/2 ]);
kk = kk + 1 - mod(kk,2);

% ii(j) keeps track of which entry in kk the jth fun is at, so that NN(j) = kk(ii(j)); 
ii = ones(1,numints); %ii(2) = 2;
NN = mat2cell(0*ii,1,bks);

% Initialization
funs = fun;
x = cell(1,syssize);
hpy = zeros(1,numints); 

% Horizontal and vertical scale
hs = max(abs(ends),[],2);
sclh = hs*2./diff(ends,[],2);
sclv = zeros(numints,1);

if iscell(op), op = op{:}; end

%%% %%%%%%%%%%%%%%%% NON-ADAPTIVE PROCEDURE %%%%%%%%%%%%%%%%% %%%
if isfield(pref,'n')
    NN = pref.n;
    % Construct the evaluation points
    if iscell(NN) && numel([NN{:}])~=numints
        for j = 1:syssize
            if numel(NN{j})~=bks(j)
                NN{j} = repmat(NN{j},1,bks(j));
            end
        end
    elseif isnumeric(NN)
        if numel(NN) == numints
            NN = mat2cell(NN,1,bks);
        elseif numel(NN) == 1
            N = NN; NN = cell(syssize,1);
            for j = 1:syssize
                NN{j} = repmat(N,1,bks(j));
            end
        else % (assuming that numel(N) == syssize)
            N = NN; NN = cell(syssize,1);
            for j = 1:syssize
                NN{j} = repmat(N(j),1,bks(j));
            end
        end
    end
    for j = 1:syssize
        x{j} = chebpts(NN{j},oldends{j});
    end
    % Evaluate the function
    if nargin(op) == 3
        v = op(x,NN,bks);
    else
        v = op(x);
    end
    
    % If it's not really a system, allow the user to return a vector.
    if syssize == 1 && isnumeric(v)
        v = {v};
    end
    
    % Convert into funs
    l = 1;
    for j = 1:syssize
        cNNj = cumsum([0 NN{j}]);   % For indexing 
        for k = 1:bks(j)
            % Get the right parts.
            indx = cNNj(k)+(1:NN{j}(k));
            vjk = v{j}(indx)';
            % Set fun scales (horizontal and vertical).
            sclv(l) = max(sclv(l), norm(vjk,inf));
            scl = struct('h',sclh(l),'v',sclv(l));
            % The new fun.
            fn = set(fun(vjk,ends(l,:)),'scl',scl);   
            funs(l) = extrapolate(fn,pref);  % Extrapolate if need be.
            l = l + 1;
        end
    end 
    hpy = 1; % Force happiness.
end

% NN
v = []; NNold = NN;

%%% %%%%%%%%%%%%%%%%%%% ADAPTIVE PROCEDURE %%%%%%%%%%%%%%%%%%%% %%%
while any(~hpy) && all([NN{:}] < maxn) && all(ii <= numel(kk))
    % Generate points in each interval and place in a cell array.
    NN = mat2cell(kk(ii),1,bks);
    for j = 1:syssize
        if ~all(NN{j} == NNold{j}),                
            x{j} = chebpts(NN{j},oldends{j}); 
        end
    end
    
    if isfield(pref,'map')
        for j = 1:syssize
            if ~all(NN{j} == NNold{j}),     
                if numel(pref.map) == 1
                    x{j} = pref.map.for(x{j}); 
                else
                    error
%                     for l = 1:numel(pref.map)
%                         mask = x{j} > pref.map(l).par(1) & x{j} < pref.map(1).par(2);
%                         x{j}(mask) = pref.map(l).for(x{j}(mask));
%                     end
                end
            end
        end
    end
    
    if ~pref.resampling
        for j = 1:syssize
            if all(NN{j}==NNold{j}), x{j} = x{j}([1 end]); end
        end
    end
    
    % Get function values.
    if nargin(op) == 3
        v = op(x,NN,oldends);
    else
        v = op(x);
    end
    
    % If it's not really a system, allow the user to return a vector.
    if syssize == 1 && isnumeric(v)
        v = {v};
    end
    
    if ~pref.resampling
        for j = 1:syssize
            if all(NN{j}==NNold{j}), v{j} = vold{j}; end
        end
    end
    
    % Get funs and test for happiness.
    l = 1;
    for j = 1:syssize
        cNNj = cumsum([0 NN{j}]);   % For indexing 
        
        for k = 1:bks(j)
            % Get the right parts.
            indx = cNNj(k)+(1:NN{j}(k));
            vjk = v{j}(indx).';

            % Set fun scales (horizontal and vertical).
            sclv(l) = max(sclv(l), norm(vjk,inf));
            scl = struct('h',sclh(l),'v',sclv(l));
              
            % The new fun.
            fn = set(fun(vjk,ends(l,:)),'scl',scl);  
            if isfield(pref,'map')
                fn.map = pref.map;
            end
            fn = extrapolate(fn,pref);          % Extrapolate if need be

            % Happiness test.
            [hpy(l),funs(l)] = ishappy(op,fn,pref);

            % If not happy, increase N.
            if ~hpy(l), ii(l) = ii(l) + 1;  end
  
            l = l + 1;
        end
    end   
    
    NNold = NN; vold = v;

end 

% if any(~hpy) && ~pref.splitting
%     warning('CHEBFUN:chebsys',['Function not resolved, using ',num2str(maxn),' pts.']);
% end

% Set chebfuns
fout = cell(1,syssize); l = 1; 
% dom = zeros(syssize,2);
for j = 1:syssize
    tmp = chebfun;
    for k = 1:bks(j)
        tmp = [tmp ; set(chebfun,'funs',funs(l),'ends',ends(l,:),...
              'imps',[funs(l).vals(1) funs(l).vals(end)],'trans',0)];
        l = l+1;
    end
    fout{j} = tmp;
%     dom(j,:) = get(tmp,'domain');
end

% % Return a chebfun or quasimatrix where possible. 
% if syssize == 1, 
%     fout = fout{:}; 
% else
%     if all(dom(:,1) == dom(1,1)) && all(dom(:,2) == dom(1,2))
%         % Domains are the same, we can make a quasimatrix
%         tmp = fout; fout = chebfun;
%         for j = 1:syssize
%             fout(:,j) = tmp{j};
%         end   
%     end
% end



function  [ish,g] = ishappy(op,g,pref)
% ISHAPPY happiness test for funs
%   [ISH,G2] = ISHAPPY(OP,G,X,PREF) tests if the fun G is a good approximation 
%   to the function handle OP. ISH is either true or false. If ISH is true,
%   G2 is the simplified version of G. PREF is the chebfunpref structure.

% Calling the constructor with a 'scale' option overrides that from scl.v
if isfield(pref,'scale')
    g.scl.v = max(g.scl.v,pref.scale);
end

n = g.n;                                    % Original length
g = simplify(g,pref.eps,pref.chebkind);     % Attempt to simplify
ish = g.n < n;                              % We're happy if this worked.

% % Antialiasing procedure ('sampletest')
% if ish && pref.sampletest 
%     x = chebpts(g.n); % Points of 2nd kind (simplify returns vals at 2nd kind points)
%     if g.n == 1
%         xeval = 0.61; % Pseduo-random test value
%     else
%         % Test a point where the (finite difference) gradient of g is largest
%         [ignored indx] = max(abs(diff(g.vals))./diff(x));
%         xeval = (x(indx+1)+1.41*x(indx))/(2.41);
%     end
%     v = op(g.map.for(xeval)); 
%     if norm(v-bary(xeval,g.vals,x),inf) > max(pref.eps,1e3*eps)*g.n*g.scl.v
%     % If the fun evaluation differs from the op evaluation, sample test failed.
%         ish =  false;
%     end
% end
