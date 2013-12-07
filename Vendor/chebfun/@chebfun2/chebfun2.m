% CHEBFUN2 Constructor for chebfun2 objects
% 
% CHEBFUN2(F) constructs a chebfun2 object for the function F on the 
% default domain [-1,1] x [-1 1]. F can be a string, e.g. 'sin(x.*y)', a
% function handle, e.g. @(x,y) x.*y + cos(x), or a matrix of values. For 
% the first two, F should in most cases be "vectorized" in the sense that
% it may be evaluated at a matrix of points and return a matrix output.
%
% If F is a matrix, A = (aij), the numbers aij are used as function values
% at tensor Chebyshev points of the 2nd kind. 
%
% CHEBFUN2(F,[A B C D]) specifies a rectangle [A B]x[C D] where the 
% function is defined. A, B, C, D must all be finite.
% 
% CHEBFUN(F,'coeffs') where F is matrix uses the matrix as coefficients in 
% a Chebyshev tensor expansion.
%
% See also CHEBFUN, CHEBFUN2V.

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun2 information.

classdef chebfun2
    properties  ( GetAccess = 'public' , SetAccess = 'public' )
          fun2        % a chebfun2 is a fun2.
          nfun2       % number of fun2 objects (always one in this version)
          corners     % Corners of rectangular domain. 
          scl = 0;    % Vertical scale used for determining relative 
                      % machine precision.
    end
    properties  ( GetAccess = 'private' , SetAccess = 'private' )
        
    end
    methods
        % Main constructor. Implementation is the private function ctor.m 
        function g = chebfun2 ( varargin )
            if( nargin == 0 )
                % return an empty chebfun2 object. 
            else
                g = ctor(g , varargin{:} );  % pass to constructor. 
            end
        end
    end
end