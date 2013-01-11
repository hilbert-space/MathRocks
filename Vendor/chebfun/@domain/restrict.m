function A = restrict(d1,d2)
% Restriction operator from one domain to a subdomain.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 2
    error('CHEBFUN:domain:restrict:nargin','Two inputs required to domain/restrict.');
end

if isa(d1,'domain'), d1 = d1.ends; end
if isa(d2,'domain'), d2 = d2.ends; end

% Nothing to do here
if d1(1) == d2(1) && d1(end) == d2(end)
    A = eye(domain(d1));
    return
end

% Define the oparray
oper = @(u) restrict(u,d2);

% inherit interior breaks from both domains
d = union(d1,d2);
d1 = domain(d);
d(d < d2(1) | d > d2(end)) = [];
d = domain(d);

% Construct the linop
A = linop( @(n) mat(n), oper, d1 );
A.isdiag = 1;

    % Define the mat
    function m = mat(n)
    breaks = [];
    % Unwrap the input
    if iscell(n)
        breaks = n{3}; 
        if isa(breaks,'domain'), breaks = breaks.ends; end
        n = n{1};
    end

    % Inherit the breakpoints from the domain.
    breaks = unique([breaks, d.ends]);
    numints = numel(breaks)-1;
    if numel(n) == 1, n = repmat(n,1,numints); end
    % Throw away breaks outside the target domain
    breaks(breaks < d.ends(1) | breaks > d.ends(end)) = [];
    
    % Find the sizes of varmats ignored to the left and the right
    maskl = d1.ends < breaks(1); 
    if ~isempty(maskl), maskl(end) = []; end
    sl = sum(n(maskl));
    maskr = d1.ends > breaks(end); 
    if ~isempty(maskr), maskr(1) = []; end
    sr = sum(n(maskr));
    s = sum(n) - sl - sr;

    % Construct the new matrix
    m = [zeros(s,sl) speye(s,s) zeros(s,sr)];
    end

end