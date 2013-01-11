function V = null(N,varargin)
%NULL  Find null-functions of a linear chebop.
% Z = NULL(A) is a chebfun quasimatrix orthonormal basis for the null space
% of the linop A. That is, A*Z has negligible elements, size(Z,2) is the
% nullity of A, and Z'*Z = I. A may contain linear boundary conditions, but
% they will be treated as homogeneous.
%
% Example 1:
%  L = chebop(@(u) diff(u),[0 pi]);
%  V = null(L);
%  norm(L*V)
%
% Example 2:
%  L = chebop(@(x,u) 0.2*diff(u,3) - diag(sin(3*x))*diff(u));
%  L.rbc = 1;
%  V = null(L)
%
% For systems of equations, NULL(S) returns a cell array of quasimatrices, 
% where the kth element in the cell, Z{k}, corresponds to the kth variable.
%
% See also chebop/svds, linop/null, chebop/eigs

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information..

% Linearize and check whether the chebop is linear
try
    L = linop(N);
    if ~isempty(varargin) && isa(varargin{1},'chebop')
        varargin{1} = linop(varargin{1});
    end
catch ME
    if strcmp(ME.identifier,'CHEBOP:linop:nonlinear')
        error('CHEBOP:eigs',['Chebop appears to be nonlinear. ',...
            'Currently, null only\nhas support for linear chebops.']);
    else
        rethrow(ME)
    end
end

V = null(L,varargin{:});

end
