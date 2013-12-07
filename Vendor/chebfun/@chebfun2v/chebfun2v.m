% CHEBFUN2V Class constructor for chebfun2v objects
% 
% CHEBFUN2V(F,G) constructs a chebfun2v with two components from the function handles F
% and G.  F and G can also be chebfun2 objects or any other object that the
% chebfun2 constructor accepts.  Each component is represented as a chebfun2. 
%
% CHEBFUN2V(F,G,H) constructs a chebfun2v with three components from the
% function handles F, G, and H.  F, G, and H can also be chebfun2 objects 
% or any other object that the chebfun2 constructor accepts. 
%
% CHEBFUN2V(F,G,[A B C D]) constructs a chebfun2v object from F and G 
% on the domain [A B] x [C D].
%
% CHEBFUN2V(F,G,H,[A B C D]) constructs a chebfun2v object from F, G, and 
% H on the domain [A B] x [C D].
% 
% See also CHEBFUN2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

classdef chebfun2v
    properties  ( GetAccess = 'public' , SetAccess = 'public' )
        xcheb   % first component a vector valued function
        ycheb   % second component a vector valued function
        zcheb   % third component a vector valued function (maybe empty).
        isTransposed % is it a row vector?
    end
    properties  ( GetAccess = 'private' , SetAccess = 'private' )
        
    end
    methods
        function g = chebfun2v ( varargin )
            if( nargin == 0 )
            else
                g = ctor(g , varargin{:} );  % pass to constructor. 
            end
        end
    end
end