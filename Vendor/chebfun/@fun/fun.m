% FUN	Class definition for funs
% FUN(OP,ENDS) constructs a fun object for the function OP.  If OP is a string,
% such as '3*x.^2+1', or a function handle, FUN(OP) automatically determines
% the number of points for OP. If OP is a vector, FUN(OP) constructs a fun
% object such that its function values are the numbers in OP.
%
% FUN(OP,ENDS,N) where N a positive integer creates a fun for OP with N Chebyshev
% points. This option is not adaptive.
%
% FUN(OP,ENDS,PREF,SCL) creates a fun for OP adaptively using the
% preferences provided in the structure PREF (see chebfunpref).  
% Here SCL is a structure with fields SCL.H (horizontal scale) and SCL.V 
% (vertical scale).
%
% FUN(C) for a cell array C creates a vector of funs using the entries of
% C as its arguments, i.e. [ fun( C{1}{:} ) , fun( C(2){:} ) , ... ].
%
% Additionally, exponents can be pass within PREF by attaching them in a cell
% array to PREF.EXPS, and a non-adaptive call can be forced by setting
% PREF.N to be a positive integer.
%
% FUN creates an empty fun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

classdef fun
    
    properties ( GetAccess = 'public' , SetAccess = 'public' )
        n = 0;          % Length of the fun
        vals = [];      % Values at Chebyshev points 
        coeffs = [];    % Chebyshev coefficients
        exps = [0 0];   % Exponents
        scl = struct('h',[],'v',[]); % Scale (horizontal and vertical)
        map = struct('for',[],'inv',[],'der',[],'name',[],'par',[]); % map
    end
    
    properties ( GetAccess = 'private' , SetAccess = 'private' )
        ish = true;     % Is happy?
    end
    
    methods
        
        function g = fun(varargin)
            if nargin == 0
                % Do nothing
            elseif nargin == 1 && iscell( varargin{1} ),
                data = varargin{1}; 
                f0 = fun;                   % Create a dummy fun
                for k = 1:length(data)      % Loop over 
                    g(k) = ctor( f0 , data{k}{:} );
                end
            else
                g = ctor( g , varargin{:} );
            end
        end      
        
    end
end
