function f = ctor_nonadapt(f,ops,ends,n,pref)
%CTOR_NONADAPT  non-adaptive chebfun constructor
% CTOR_NONADAPT handles non-adaptive construction of chebfuns.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(ends)
    error('CHEBFUN:ctor_nonadapt:emptydomain','Cannot construct chebfun on an empty domain.'); 
elseif length(ends) ~= length(ops)+1
    error('CHEBFUN:ctor_nonadapt:input_intsfun',['Unrecognized input sequence: Number of intervals '...
        'do not agree with number of funs.'])
end
if length(n) ~= length(ops)
    if length(n) == 1
        n = repmat(n,1,length(ops));
    else
        error('CHEBFUN:ctor_nonadapt:input_ptsfun',['Unrecognized input sequence: Number of Chebyshev '...
        'points was not specified for all the funs.'])
    end
end
if any(diff(ends)<0), 
    error('CHEBFUN:ctor_nonadapt:input_endsvals',['Vector of endpoints should have increasing values.'])
end
if any(n-round(n))
    error('CHEBFUN:ctor_nonadapt:input_numpts',['Vector with number of Chebyshev points should consist of'...
        ' integers.'])
end

if nargin < 5, pref = chebfunpref; end
funs = [];

% Sort out whatever exponents have been passed.
if isfield(pref,'exps') 
    exps = pref.exps;
%     if iscell(exps), exps = cell2mat(exps); end  % Convert cell to vector
    if numel(exps) == 1, 
    % Only one exponent supplied, so repeat as necessary
        exps = exps(ones(1,2*numel(ends)-2));
    elseif numel(exps) == 2, 
    % Exponents only supplied at ends. Fill in those at breakpoints with
    % NaNs if splitting is on, or zeros if slitting is off.
        if pref.blowup, ee = NaN; else ee = 0; end
        tmp = repmat(ee,1,2*numel(ends)-4);
        exps = [exps(1) tmp exps(2)];
    elseif numel(exps) == numel(ends)
    % Exponents supplied at breakpoints. Assume the same on either side.
        exps = exps(ceil(1:.5:numel(exps)-.5));  
    elseif numel(exps) ~= 2*numel(ends)-2
    % Something is wrong.
        error('CHEBFUN:ctor_nonadapt:exps_input2','Length of vector exps must correspond to breakpoints.');
    end
end

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

% NOTE: Don't use an i variable, as this can  mess 
% up function construction from string inputs.
ii = 0;
while ii < length(ops)
    ii = ii + 1;
    op = ops{ii};
    es = ends(ii:ii+1);
    switch class(op)
        case 'function_handle'
            a = es(1); b = es(2);
            [op flag] = vectorcheck(op,[a b],pref);    
            if ~isempty(flag)
                % Force systems
                pref.n = n;
                [op ends] = vectorcheck(op,ends,pref);
                f = growsys(op,ends,pref);
                return
            end           
            pref.n = n(ii);
            if isfield(pref,'exps'), pref.exps = exps(2*ii+(-1:0)); end
            if ~isfield(pref,'map')
                g = fun(op, [a b], pref);
            else
                g = fun(op, maps(pref.map,es), pref);
            end
            funs = [funs g];
        case 'char'
            sop = str2num(op);
            if ~isempty(sop)
                ops{ii} = sop;
                ii = ii-1; es = []; fs = [];
                continue
            end
            a = ends(ii); b = ends(ii+1);
            op = str2op(op);
            op = vectorcheck(op,[a b],pref);
            ops{ii} = op;
            pref.n = n(ii);
            if isfield(pref,'exps'), pref.exps = exps(2*ii+(-1:0)); end
            if ~isfield(pref,'map')
                g = fun(op, [a b], pref);
            else
                g = fun(op, maps(pref.map,es), pref);
            end
            funs = [funs g];
        case {'chebfun','chebconst'}
            a = es(1); b = es(2);
            if op.ends(1) > a || op.ends(end) < b
                error('CHEBFUN:ctor_nonadapt:domain','chebfun is not defined in the domain.')
            end
            if isfield(pref,'trunc')
                error('CHEBFUN:ctor_nonadapt:trunc','''trunc'' cannot be used in nonadaptive call.')
            end
            pref.n = n(ii);
            if isfield(pref,'exps'), pref.exps = exps(2*ii+(-1:0)); end
            if ~isfield(pref,'map')
                g = fun(@(x) feval(op,x), [a b], n(ii));
                % Need to maintain same Jacobian information
                f.jacobian = op.jacobian;
            else
                g = fun(@(x) feval(op,x), maps(pref.map,es), n(ii));
            end
            funs = [funs g];
        case 'double'
            warning('CHEBFUN:ctor_nonadapt:vecpts',['Generating fun from a numerical vector. '...
                'Associated number of Chebyshev points is not used.']);
            g = ctor_adapt(f,{op},es,pref); g = g.funs(1);
            funs = [funs g];           
        case 'fun'
            if numel(op) > 1
                error('CHEBFUN:ctor_nonadapt:vecfuns',['A vector of funs cannot be used to construct '...
                    ' a chebfun.'])
            end
            error('CHEBFUN:ctor_nonadapt:funpts',['Generating fun from another. '...
                'Associated number of Chebyshev points is not used.']);
        case 'cell'
            error('CHEBFUN:ctor_nonadapt:incell',['Unrecognized input sequence: Attempted to use '...
                'more than one cell array to define the chebfun.'])
        otherwise
            error('CHEBFUN:ctor_nonadapt:inop',['The input argument of class ' class(op) ...
                'cannot be used to construct a chebfun object.'])
    end
    scl.v = max(scl.v, g.scl.v);
    scl.h = max(scl.h, g.scl.h);
end

% First row of imps contains function values
imps = jumpvals(funs,ends,ops,pref,scl.v); 
imps(1,abs(imps(1,:))<2*eps*scl.v & isinf(ends)) = 0; % Cheat at ends of unbounded domains
scl.v = max(scl.v,norm(imps(~isinf(imps)),inf));

% update scale field in funs
f.nfuns = length(ends)-1; 
for k = 1:f.nfuns
    funs(k).scl = scl;   
end

% Assign fields to chebfuns.
f.funs = funs; f.ends = ends; f.imps = imps; f.trans = false; f.scl = scl.v;
f.ID = newIDnum();

function op = str2op(op)
% This is here as it's a clean function with no other variables hanging around in the scope.
depvar = symvar(op); 
if numel(depvar) ~= 1, 
    error('CHEBFUN:ctor_nonadapt:indepvars', ...
        'Incorrect number of independent variables in string input.'); 
end
op = eval(['@(' depvar{:} ')' op]);
