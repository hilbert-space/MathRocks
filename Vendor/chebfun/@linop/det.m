function d = det(L,tol)
%DET    Determinant of a linop
% Compute the determinant of a linear operator. This is a well-defined
% notion for trace-class perturbations of the identity operator. Most
% notably, for perturbations that are Fredholm integral operators, this
% gives the famous Fredholm determinant.
%
% Example: 
%   dom = domain(-1,1);
%   F = eye(dom) + fred(@(x,y) sin(x-y),dom);
%   d = det(F);
%   disp([d ; (cos(4)+15)/8]);

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% For differential operators the determinant will be +/- infinity.
if any(L.difforder > 1), d = inf; return, end

if nargin < 2, tol = 100*chebfunpref('eps'); end  % Aim for this tolerance

% Choose a sensible number of points to discretise at (same as growfun)
maxn = cheboppref('maxdegree');
l2n = log2(maxn-1);
maxn = 2.^ceil(l2n)+1;
maxpower = max(4,floor(log2(maxn-1)));
npn = max(min(maxpower,6),3);
nn = 1 + round(2.^[ (3:npn) (2*npn+1:2*maxpower)/2 ]);
nn = nn + 1 - mod(nn,2);

% Initialise the stored value
d = 0; 
dold = inf;

for n = nn
    
    % Evaluate the operator on a Chebyshev grid
    d = det(feval(L,n));

    % Check for convergence
    err = abs(d-dold);
    ish = err <= tol;
    dold = d;

    % If happy, we're done!
    if ish, return, end

end

warning('LINOP:det:NoConverge',...
    ['Failed to converge with ',int2str(n),' points.\n' ...
     'Estimated error is ', num2str(err) '.'])
