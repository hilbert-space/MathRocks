function A = diag(f,d)
% DIAG   Pointwise multiplication operator.
% A = DIAG(F,D) produces a chebop that stands for pointwise multiplication
% by the function F on the domain D.
%
% See also chebfun/diag, chebop, linop/mtimes

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 2
    error('CHEBFUN:domain:diag:nargin','Two inputs required to domain/diag.');
end

% Switch f and d (as in a call from chebfun/diag)
if isa(f,'domain')
    tmp = f; f = d; d = tmp;
end

% Unset funreturn flag, as we want to evaluate f and get back doubles
% f = set(f,'funreturn',0);

% Sort out the domain
fends = f.ends; fends(fends<d.ends(1) | fends>d.ends(end)) = [];
f.funreturn = 0;
d = domain(union(d.ends,fends));

% Define the oparray
if isa(f,'chebfun')
    if numel(f) > 1
        error('CHEBFUN:domain:diag:quasi','Quasimatrix input not allowed.');
    end
    oper = @(u) times(f,u);
else
    oper = @(u) chebfun(@(x) feval(f,x).*feval(u,x),d);
end

% Construct the linop
A = linop( @(n) mat(d,f,n), oper, d  );
A.isdiag = 1; % Which is obviously diagonal

end

% Define the mat
function m = mat(d,f,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(breaks) && isempty(map)
    % No breaks or map
    xpts = chebpts(n,d.ends([1 end]));
    xpts = trim(xpts);
    fx = feval( f, xpts );
elseif isempty(breaks)
    % No breaks
    if isstruct(map), map = map.for; end
    xpts = map(chebpts(n));
    xpts = trim(xpts);
    fx = feval( f, xpts );
elseif isempty(map)
    % No maps
    xpts = chebpts(n,breaks);
    xpts = trim(xpts);
    fx = feval( f, xpts );
    dxloc = cumsum(n(1:end-1));
    fx(dxloc) = feval(f, xpts(dxloc), 'left');
    fx(dxloc+1) = feval(f, xpts(dxloc), 'right');
else
    % Breaks and maps
    csn = [0 cumsum(n)];
    xpts = zeros(csn(end),1);
    if iscell(map) && numel(map) == 1
        map = map{1};
    end
    mp = map.for;
    for k = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{k}.for; end
            if isstruct(map), mp = map(k).for; end
        end
        if isstruct(mp), mp = mp.for; end
        ii = csn(k)+(1:n(k));
        xpts(ii) = mp(chebpts(n(k)));
    end
    fx = feval( f, xpts );
    dxloc = csn(2:end-1);
    fx(dxloc) = feval(f, xpts(dxloc), 'left');
    fx(dxloc+1) = feval(f, xpts(dxloc), 'right');
end
a = f.ends(1); b = f.ends(end);
fx(xpts<a | xpts>b) = 0; % Zero out entries outside domain of f.
fx = trim(fx);           % Replace infs by big numbers to avoid NaNs.
m = spdiags(fx,0,sum(n),sum(n)); % Construct the diagonal matrix.
end

function x = trim(x)
% This function forces x to be in [-10^16,10^16]
x(x==inf) = 1e18;
x(x==-inf) = -1e18;
end