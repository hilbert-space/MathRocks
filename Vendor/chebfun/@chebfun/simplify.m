function u = simplify(u,k,tol,force)
% SIMPLIFY a chebfun
%   U = SIMPLIFY(U,TOL) removes leading Chebyshev coefficients of the 
%   chebfun U that are below epsilon, relative to the verical scale 
%   stored in U.scl.v. TOL is the tolerance used in this process. 
%   IF TOL is not provided, it is retrived from CHEBFUNPREF.
%
%   U = SIMPLIFY(U,K,TOL) simplifies only the funs of U given by the 
%   entries of the integer vector K.
%
%   U = SIMPLIFY(U,TOL,'force') or SIMPLIFY(U,K,TOL,'force') forces an 
%   agressive simplify, where any trailing coefficients less than TOL are
%   removed.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% deal with input arguments
if nargin < 4, force = []; end
if nargin == 1
    tol = chebfunpref('eps');
    k = [];
    force = 0;
elseif ischar(k)
    force = k;
    k = [];
    tol = chebfunpref('eps');
else
    if min(k) < 1
        if nargin > 2, force = tol; end
        tol = max(min(k),eps);
        k = [];
    elseif nargin == 2
        tol = chebfunpref('eps');
    end
end

% Check inputs for forcing.
if ischar(k), force = k; k = [];
elseif ischar(tol), force = tol; end
force = strcmpi(force,'force');

if ~isempty(k) && numel(u)>1 && numel(u)~=length(k)
    error('CHEBFUN:simplify:quasimatrices',['For quasimatrices, '...
        'second imput must be a vector with length matching the '...
        'number of columns or rows in the quasimatrix'])
end
kfun = k(:)';

for j = 1:numel(u)

    % If there are any funs, simplify them.
    if ~isempty( u(j).funs )
        u(j).funs = simplify( u(j).funs , tol , [] , force );
    end
    
end
