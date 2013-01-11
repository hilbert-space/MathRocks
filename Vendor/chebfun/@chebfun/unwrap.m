function p = unwrap(p,varargin)
%UNWRAP Unwrap chebfun phase angle.
%   UNWRAP(P) unwraps radian phases P by changing absolute jumps greater
%   than or equal to pi to their 2*pi complement. It unwraps along the
%   continuous dimension of P and leaves the first fun along this dimension
%   unchanged.
%
%   UNWRAP(P,TOL) uses a jump tolerance of TOL rather than the default 
%   TOL = pi.
%
%   See also UNWRAP, CHEBFUN/ABS, CHEBFUN/ANGLE.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(varargin) > 2 
    dim = varargin{2};
    if (dim == 1 && ~p(1).trans) || (dim == 2 && p(1).trans)
        warning('CHEBFUN:unwrap:dim',['Unwrap only operates along the ',...
            'continuous dimension of a quasimatrix.']);
    end
    varargin(2) = [];
end

% Get the shifts. By default these are pi.
if numel(varargin) > 1
    jumptol = varargin{:};
else 
    jumptol = pi;
end

% Loop over the columns
for k = 1:numel(p);
    p(k) = colfun(p(k),jumptol);
end


function p = colfun(p,jumptol)

% Trivial case
if p.nfuns == 1, return, end

% Store data about the imps for later
tol = 100*chebfunpref('eps')*p.scl;
lvals = feval(p,p.ends,'left');
rvals = feval(p,p.ends,'right');
idxl = abs(p.imps(1,:) - lvals) < 100*tol;
idxr = abs(p.imps(1,:) - rvals) < 100*tol;

idx1 = mymod(abs(lvals - rvals),2*jumptol) <  tol;
idx2 = abs(lvals - rvals) > tol;
idx = idx1 & idx2;
scale = round((lvals - rvals)/(2*jumptol));
shift = cumsum(idx.*scale*2*jumptol);
for j = 2:p.nfuns
    p.funs(j) = p.funs(j)+shift(j);
end

% % In the olden days we used to us the built-in unwrap...
% % Get the indices of the break points
% n = zeros(p.nfuns,1);
% idx = zeros(p.nfuns,1);
% for k = 1:p.nfuns
%     n(k) = p.funs(k).n; 
%     % There can be problems if the length is <= 2, so prolong to 3.
%     if n(k) <= 2;
%         idx(k) = n(k);
%         p.funs(k) = prolong(p.funs(k),3);
%         n(k) = 3;
%     end
% end
% csn = [0 ; cumsum(n)];
% 
% % Simply call built-in UNWRAP on the values
% v = get(p,'vals');
% w = unwrap(v);
% 
% % Update to the new values
% for k = 1:p.nfuns
%     p.funs(k).vals = w(csn(k)+(1:n(k)));
%     % Decrease the degree if it was increased to 3 above.
%     if idx(k)
%         p.funs(k) = prolong(p.funs(k),idx(k));
%     end
% end

% Update the imps
p.imps(1,idxl) = feval(p,p.ends(idxl),'left');
p.imps(1,idxr) = feval(p,p.ends(idxr),'right');

% Merge to tidy up unneeded breakpoints;
p = merge(p,find(idx));

function m = mymod(f,g)
m = min([abs(mod(f,g)) ; abs(mod(f,-g)) ; abs(mod(-f,g)) ; abs(mod(-f,-g))]);