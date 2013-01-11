function varargout = svds(N,varargin)
%SVDS  Find some singular values and vectors of a compact linear operator.
% S = SVDS(A) returns a vector of 6 nonzero singular values of the
% linear compact chebop A, such as the FRED or VOLT operator.
% SVDS will attempt to return the largest singular values. If A is not
% linear and/or seems to be unbounded, an error is returned.
%
% [U,S,V] = SVDS(A) returns a diagonal 6x6 matrix D and two orthonormal
% quasi-matrices such that A*V = U*S.
%
% Note that an integral operator smoothest the right-singular vectors V.
% Hence finding these vectors is a problem with possibly large backward
% errors and one must expect that the vectors in V are not accurate to
% machine eps. However, the left sing. vectors U have fine accuracy.
%
% SVDS(A,K) computes the K largest singular values of A.
%
% SVDS(A,K,SIGMA) tries to compute K singular values closest to a scalar
% shift SIGMA. Note, however, that for compact operators there are
% infinitely many singular values close to or at zero!
%
%
% Example:
%   d = domain(0,pi);
%   A = fred(@(x,y)sin(2*pi*(x-2*y)),d);
%   [U,S,V] = svds(A);
%
% See also linop/eigs.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Linearize and check whether the chebop is linear
try
    L = linop(N);
    if ~isempty(varargin) && isa(varargin{1},'chebop')
        varargin{1} = linop(varargin{1});
    end
catch ME
    if strcmp(ME.identifier,'CHEBOP:linop:nonlinear')
        error('CHEBOP:svds',['Chebop appears to be nonlinear. Currently, svds only' ...
            '\nhas support for linear chebops.']);
    else
        rethrow(ME)
    end
end

[varargout{1:nargout}] = svds(L,varargin{:});

end
