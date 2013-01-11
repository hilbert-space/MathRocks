function F = add_breaks_at_roots(F,tol,r)
% Adds new breakpoints at the roots of a chebfun. These can be passed in
% the third input if already computed elsewhere.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1 || isempty(tol),
    tol = 50*chebfunpref('eps');
end

% Find the roots
ends = get(F,'ends');
if nargin < 3
    r = roots(F);
elseif isempty(r)
    return
end

% Prune out ones that are near to existing breakpoints
for k = 1:length(r)
    nearends = min(abs(r(k)-ends));
    if nearends < tol, r(k) = NaN; end
end
r(isnan(r)) = [];

% Add the new breaks
if ~isempty(r)
    F = define(F,r,0);
end

