%FUN2 Class definition for fun2 objects
%
% FUN2(OP) constructs a fun2 object for the function OP on the default 
% domain [-1,1]x[-1,1].
%
% FUN2(OP,ENDS) constructs a fun2 object on the domain given by ENDS.
% 
% This class is mainly for developers and is not intended to be accessed
% directly by a user. 
%
% See CHEBFUN2

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

classdef fun2
    properties  ( GetAccess = 'public' , SetAccess = 'public' )
        rank        % Approximation rank
        C           % Left chebvectors
        U           % Pivot values
        R           % Right chebvectors
        scl = 0     % Magnitude of fun2.
        map = struct('for',[],'inv',[],'name',[]);         % Linear map to scale to unit square. 
        PivPos      % Position of the cross for the approximation (only required for pretty plotting).
    end
    properties  ( GetAccess = 'private' , SetAccess = 'private' )
        
    end
    methods
        function g = fun2 ( varargin )
            if( nargin == 0 )
            else
                g = ctor( g, varargin{:} );  % pass to constructor. 
            end
        end
    end
end