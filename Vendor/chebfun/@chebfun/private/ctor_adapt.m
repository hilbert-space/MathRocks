function f = ctor_adapt(f,ops,ends,pref)
%CTOR_ADAPT  Adaptive chebfun constructor
% CTOR_ADAPT handles adaptive construction of chebfuns.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(ends)
    error('CHEBFUN:ctor_adapt:emptydomain','Cannot construct chebfun on an empty domain.'); 
elseif length(ends) ~= length(ops)+1
    error('CHEBFUN:ctor_adapt:numints',['Unrecognized input sequence: Number of intervals '...
        'do not agree with number of funs.'])
end
if any(diff(ends)<0), 
    error('CHEBFUN:ctor_adapt:vecends','Vector of endpoints should have increasing values')
end
funs = [];

% Initial horizontal scale.
hs = norm(ends([1,end]),inf);
if isinf(hs)
   inends = ~isinf(ends);
   if any(inends)
       hs = max(max(abs(ends(inends))+1));
   else
       hs = 2;
   end
end
scl.v = 0; scl.h = hs;
newends = ends(1);
newops = {};

% Sort out whatever exponents have been passed.
if isfield(pref,'exps') 
    exps = pref.exps;
    if iscell(exps), exps = cell2mat(exps); end  % Convert cell to vector
    if numel(exps) == 0, exps = NaN; end
    if numel(exps) == 1, 
    % Only one exponent supplied, so repeat as necessary
        exps = exps(ones(1,2*numel(ends)-2));
    elseif numel(exps) == 2, 
    % Exponents only supplied at ends. Fill in those at breakpoints with
    % NaNs if splitting is on, or zeros if slitting is off.
        if pref.blowup > 0, ee = NaN; else ee = 0; end
        tmp = repmat(ee,1,2*numel(ends)-4);
        exps = [exps(1) tmp exps(2)];
    elseif numel(exps) == numel(ends)
    % Exponents supplied at breakpoints. Assume the same on either side.
        exps = exps(ceil(1:.5:numel(exps)-.5));  
    elseif numel(exps) ~= 2*numel(ends)-2
    % Something is wrong.
        error('CHEBFUN:ctor_adapt:exps_input2','Length of vector exps must correspond to breakpoints');
    end
end

if isfield(pref,'map') && isstruct(pref.map) && numel(pref.map) > 1
    map = pref.map;
else
    map = [];
end

% Support for matrix input
if length(ops) == 1 && isnumeric(ops{1}) && min(size(ops{1})) > 1
    if ~isfield(pref,'map')
        if all(isfinite(ends))
            map = maps(fun,'linear',ends);
        else
            map = maps(fun,'unbounded',ends);
        end
    end
    fcell = cell(size(ops{1},2),1);
    ftmp = chebfun(0,ends);
    for k = 1:size(ops{1},2)
%         fcell{k} = chebfun(ops{1}(:,k),pref);
%         fcell{k} = ctor_adapt(f,{ops{1}(:,k)},ends,pref);
        ftmp.funs(1) = fun(ops{1}(:,k),map,pref);
        fcell{k} = ftmp;
    end
    f = horzcat(fcell{:});
    return
end

ii = 0;
while ii < length(ops)
    ii = ii + 1;
    op = ops{ii};
    es = ends(ii:ii+1);
    if isfield(pref,'exps'), pref.exps = exps(2*ii+(-1:0)); end
    if ~isempty(map),        pref.map = map(ii);            end
    switch class(op)
        case 'double'
            if isfield(pref,'coeffs')
                if pref.coeffkind == 2
                % Coeffs of 2nd-kind are given. Convert to 1st-kind.    
                    N = length(op)-1;
                    op = 2*op(end:-1:1);
                    c = op;
                    for k = N-1:-1:2, c(k) = op(k) + c(k+2);    end
                    if  N > 2,        c(1) = .5*(op(1) + c(3)); end
                    op = c(end:-1:1);
                end
                op = chebpolyval(op,pref.chebkind);
            end
            if ~isfield(pref,'map')
                fs = fun(op,es,pref);
            else
                fs = fun(op,maps(pref.map,es),pref);
            end
            scl.v = max(scl.v, fs.scl.v);
        case 'fun'
            if numel(op) > 1
            error('CHEBFUN:ctor_adapt:vecin',['A vector of funs cannot be used to construct '...
                ' a chebfun.'])
            end
            if norm(op.map.par(1:2)-es) > scl.h*1e-15
                error('CHEBFUN:ctor_adapt:domain','Inconsistent domains')
            else
                fs = op;
                scl.v = max(scl.v, fs.scl.v);
            end
        case 'char'
            sop = str2num(op);
            if ~isempty(sop)
                ops{ii} = sop;
                ii = ii-1; es = []; fs = [];
            else
                op = str2op(op);
                op = vectorcheck(op,es,pref); 
                [fs,es,scl] = auto(op,es,scl,pref);
            end
        case 'function_handle'
            [op flag] = vectorcheck(op,es,pref);
            if ~isempty(flag)
                % Force systems
                [op ends] = vectorcheck(op,ends,pref);
                f = autosys(op,ends,pref);
                return
            end
            [fs,es,scl] = auto(op,es,scl,pref);
        case {'chebfun','chebconst'}
            if numel(op) > 1
                error('CHEBFUN:ctor_adapt:onechebfun','Cannot construct from quasimatrices in this way.');
            end
            if op.ends(1) > ends(1) || op.ends(end) < ends(end)
                 warning('CHEBFUN:ctor_adapt:domain','chebfun is not defined in the domain')
            end
            if isfield(pref,'exps'), pref.exps = exps(2*ii+(-1:0)); end
            if ~isfield(pref,'trunc') && isempty(map)
                op = restrict(op,es);
                fs = op.funs; es = op.ends; scl.v = max(op.scl,scl.v);
            else
                [fs,es,scl] = auto(@(x) feval(op,x),es,scl,pref);
            end
        case 'cell'
            error('CHEBFUN:ctor_adapt:inputcell',['Unrecognized input sequence: Attempted to use '...
                'more than one cell array to define the chebfun.'])
        otherwise
            error('CHEBFUN:ctor_adapt:inputclass',['The input argument of class ' class(op) ...
                ' cannot be used to construct a chebfun object.'])
    end
    % Concatenate funs, ends and handles (or ops)   
    funs = [funs fs];
    newends = [newends es(2:end)];
    for k = 1:numel(fs), newops{end+1} = op; end;
end

nfuns  = length(newends)-1; 

% If splitting is not done accurately, scales may be incorrectly large. To
% fix this, a second call to the constructor is needed. 
% Check for exponents and try a second time. Add a new
% field to pref to break the recursion on second call.
if ~isfield(pref,'secondcall') && pref.splitting && pref.blowup
    pref.secondcall = true;
    userends = ismember(newends,ends)';  % ends defined by user must be kept
    % Check if there are blowups at either endpoints
    exps = zeros(nfuns,2);
    for k = 1:nfuns
       exps(k,:) = funs(k).exps;    
    end
    eak = [1 ; exps(1:nfuns-1,2) | exps(2:nfuns,1); 1];
    mask = ~userends & ~eak;
    newends(mask) = [];
    newops(mask) = [];
    pref.exps = [exps(~mask(1:end-1),1) exps(~mask(2:end),2)].';
    f = ctor_adapt(f,newops,newends,pref);
    return
end

imps = jumpvals(funs,newends,newops,pref,scl.v);   % Update values at jumps, first row of imps.
if ~isempty(imps)
    imps(1,abs(imps(1,:))<2*eps*scl.v & isinf(newends)) = 0; % Cheat at ends of unbounded domains
end
scl.v = max(scl.v,norm(imps(~isinf(imps)),inf));
f.nfuns = nfuns;
% update scale and check if simplification is needed.
for k = 1:f.nfuns
    funscl = funs(k).scl.v;
    funs(k).scl = scl;      % update scale field
    if  funscl < scl.v/10   % if scales were significantly different, simplify!
        funs(k) = simplify(funs(k),pref.eps);
    end
end

% Assign fields to chebfuns.
f.funs = funs; f.ends = newends; f.imps = imps; f.trans = false; f.scl = scl.v;
f.ID = newIDnum();
if length(f.ends)>2         
     f = merge(f,find(~ismember(newends,ends)),pref); % Avoid merging at specified breakpoints
end

function op = str2op(op)
% This is here as it's a clean function with no other variables hanging around in the scope.
depvar = symvar(op); 
if numel(depvar) ~= 1, 
    error('CHEBFUN:ctor_adapt:indepvars', ...
        'Incorrect number of independent variables in string input.'); 
end
op = eval(['@(' depvar{:} ')' op]);
 
