function Fout = comp(F1, op, F2, pref)
% FOUT = COMP(F1,OP,F2)
% COMP(F1,OP) returns the composition of the chebfun F with OP, i.e.,
%   FOUT = OP(F1).
% COMP(F,OP,F2) returns the composition of OP with chebfuns F and F2 with, 
%   i.e., FOUT = OP(F1,F2).
%
% Examples
%        x = chebfun('x')
%        Fout = comp(x,@sin)
%        Fout = comp(x+1,@power,x+5)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Note: this function does not deal with deltas! It will delete them!
% Only the first row of imps is updated. 

%-------------------------------------------------------
% Deal with quasimatrices.

Fout = F1;

if nargin > 2 && isstruct(F2)
    pref = F2;
    F2 = [];
elseif nargin < 4
    pref = chebfunpref;
end

% One chebfun
if nargin < 3 || isempty(F2)
    for k = 1:min(size(F1))
        Fout(k) = compcol(F1(k), op, [], pref);
    end
% Two chebfuns    
else        
    if size(F1) ~= size(F2)
        error('CHEBFUN:comp:QMdimensions','Quasimatrix dimensions must agree.')
    end
    if isa(Fout,'chebconst'), Fout = F2; end
    for k = 1:min(size(F1))
        Fout(k) = compcol(F1(k), op, F2(k), pref);
    end
end

%-------------------------------------------------------
% Deal with a single chebfun (op needs only ONE input)
function f1 = compcol(f1, op, f2, pref)

% For an empty chebfun, there is nothing to do.
if isempty(f1), return, end

% Initialise (and overlap if there are two chebfuns)
ffuns = [];
ends = f1.ends(1);
if isempty(f2)
    imps = op(f1.imps(1,1));
    if ~any(get(f1,'exps'))
        vals = get(f1,'vals');
    else
        vals = getvals(f1);
    end
    vscl = norm( op(vals), inf);
else
    [f1,f2] = overlap(f1,f2);
    imps = op(f1.imps(1,1),f2.imps(1,1));
    vscl = norm( op(f1.imps(1,:),f2.imps(1,:)), inf);
end

% We can skip the fun constructor if we know it will fail.
if isfield(pref,'skipfunconstruct')  
    skip = pref.skipfunconstruct;
    ish = false;
else
    skip = false;
end

% Loop through the funs
for k = 1:f1.nfuns
    % Update vscale (horizontal scale remains the same)
    f1.funs(k).scl.v = vscl;
    if ~skip
        % Attempt to generate funs using the fun constructor.
        if isempty(f2)
            [newfun ignored] = compfun(f1.funs(k),op,pref);
        else
            [newfun ignored] = compfun(f1.funs(k),op,f2.funs(k),pref);
        end
        ish = get(newfun,'ish');
    else
        ish = 0;
    end
    
    if ish || (~ish && ~pref.splitting && ~pref.blowup) 
    % If we're happy, or not allowed to split, this will do.
       if ~ish
            warning('CHEBFUN:comp:resolv', ...
            ['Composition with function ', func2str(op), ' not resolved using ',  ...
            int2str(newfun.n), ' pts. Have you tried ''splitting on''?']);
       end
       ffuns = [ffuns newfun];                  % Store this fun
       ends = [ends f1.ends(k+1)];              % Store the ends
       if isempty(f2)                           % Store the imps
           imps = [imps op(f1.imps(1,k+1))];
       else
           imps = [imps op(f1.imps(1,k+1),f2.imps(1,k+1))]; 
       end
       vscl = max(vscl,newfun.scl.v);           % Get new estimate for vscale
    elseif pref.splitting
    % If sad and splitting is 'on', get a chebfun for that subinterval.
       if all(isfinite(f1.ends(k:k+1)))
       % Since we know we must split at least once: 
           endsk = [f1.ends(k) mean(f1.ends(k:k+1)) f1.ends(k+1)]; 
       % We'll try to remove this below with merge.    
       else
       % For unbounded domains, we let the constructor figure out where to split.    
           endsk = f1.ends(k:k+1);
       end
       if isempty(f2)
           newf = chebfun(@(x) op(feval(f1,x)), endsk, pref);
       else
           newf = chebfun(@(x) op(feval(f1,x),feval(f2,x)), endsk, pref);
       end
       if all(isfinite(f1.ends(k:k+1)))
       % We forced a breakpoint above, try to remove it.   
           indx = find(newf.ends == endsk(2),1);
           newf = merge(newf,indx);
       end
       ffuns = [ffuns newf.funs];               % Store new funs
       ends = [ends newf.ends(2:end)];          % Store new ends
       imps = [imps newf.imps(1,2:end)];        % Store new imps
       vscl = max(vscl,newfun.scl.v);           % Get new estimate for vscale
    elseif pref.blowup
    % If sad and blowup is 'on', look for some exponents
       endsk = f1.ends(k:k+1);
       if isempty(f2)
           newf = chebfun(@(x) op(feval(f1,x)), endsk, pref);
       else
           newf = chebfun(@(x) op(feval(f1,x),feval(f2,x)), endsk, pref);
       end
       ffuns = [ffuns newf.funs];               % Store new funs
       ends = [ends newf.ends(2:end)];          % Store new ends
       imps = [imps newf.imps(1,2:end)];        % Store new imps
       % Blowup will have destroyed vscale. Make up a new one...
       vscl = max(newf.scl);                    % Get new estimate for vscale
    end
         
end

% Update scale of funs:
f1.nfuns = length(ends)-1;
for k = 1:f1.nfuns
    ffuns(k).scl.v = vscl;
end
% Put the funs back into a chebfun.
f1.funs = ffuns; f1.ends = ends; f1.imps = imps; f1.scl = vscl;


function V = getvals(f)
V = [];
for k = 1:f.nfuns
    vals = f.funs(k).vals;
    exps = f.funs(k).exps;
    if any(exps)
        map = f.funs(k).map;    
        ends = map.par(1:2);
        rescl = (2/diff(ends))^sum(exps);   
        x = chebpts(f.funs(k).n,ends);
        % hack for unbounded functions on infinite intervals
        if any(isinf(ends))
            s = map.par(3);
            if all(isinf(ends))
                rescl = .5/(5*s);
            else
                rescl = .5/(15*s);
            end
            rescl = rescl.^sum(exps);
            ends = [-1 1];   x = map.inv(x);
        end
        vals = rescl*vals.*((x-ends(1)).^exps(1).*(ends(2)-x).^exps(2));
    end
end
V = [V ; vals];