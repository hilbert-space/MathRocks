% CHEBFUN   Constructor for chebfuns.
% 
% CHEBFUN(F) constructs a chebfun object for the function F on the interval 
% [-1,1]. F can be a string, e.g 'sin(x)', a function handle, e.g 
% @(x) x.^2 + 2*x +1, or a vector of numbers. For the first two, F should 
% in most cases be "vectorized" in the sense that it may be evaluated at a 
% column vector of points x(:) and return an output of size length(x(:)).
%
% If F is a doubles array, A = [A1,A2,...,An]', the numbers A1,...,An are 
% used as function values at n Chebyshev points of the 2nd kind, i.e. 
% chebpts(n). CHEBFUN(F,'equi') is similar, but here the data is assumed to 
% come from an equispaced grid linspace(-1,1,n); in this case a smooth 
% polynomial interpolant is constructed that is derived from adaptive 
% Floater-Hormann interpolation [Numer. Math. 107, 315-331 (2007)]. If F is 
% a matrix CHEBFUN(F) returns a chebfun 'quasimatrix', taking each column 
% of F as function values in the same way as above.
%
% CHEBFUN(F,[A B]) specifies an interval [A B] where the function is
% defined. A and/or B may be infinite.
%
% CHEBFUN(F,NP) overrides the adaptive construction process to specify
% the number NP of Chebyshev points to construct the chebfun. This is
% shorthand for CHEBFUN(F,'length',NP). CHEBFUN(F,[A B],NP) specifies both
% the interval of definition and the number of points. If NP is NaN, the
% default adaptive process is used.
%
% CHEBFUN(F,...,'exps',[EXP1 EXP2]) allows the definition of singularities
% in the function F at end points of the interval. If EXP1 and/or EXP2 is 
% NaN, the constructor will attempt to determine the form of the singularity 
% automatically. See help chebfun/blowup for more information.
%
% CHEBFUN([C1,...,CN],'coeffs') constructs a chebfun corresponding to the
% Chebyshev polynomial P(x) = C1*T_{N-1}(x)+C2*T_{N-2}(x)+...+CN.
%
% CHEBFUN(F1,F2,...,Fm,ENDS), where ENDS is an increasing vector of length
% m+1, constructs a piecewise smooth chebfun for the functions F1,...,Fm.
% Each function Fi can be a string, function handle, or doubles array,
% and is defined in the interval [ENDS(i) ENDS(i+1)].
%
% CHEBFUN(CHEBS,ENDS) constructs a piecewise smooth chebfun with m pieces
% from a cell array chebs of size m x 1.  Each entry CHEBS{i} is a function 
% defined on [ENDS(i) ENDS(i+1)] represented by a string, a function handle 
% or a number.  CHEBFUN(CHEBS,ENDS,NP) specifies the number NP(i) of 
% Chebyshev points for the construction of the function in CHEBS{i}.
%
% G = CHEBFUN(...) returns an object G of type chebfun.  A chebfun consists
% of a vector of 'funs', a vector 'ends' of length m+1 defining the
% intervals where the funs apply, and a matrix 'imps' containing information
% about possible delta functions at the breakpoints between funs.
% CHEBFUN(F,[A B]) specifies an interval [A B] where the function is
% defined. A and/or B may be infinite. Calling CHEBFUN with no inputs 
% creates an empty chebfun.
%
% G = CHEBFUN(...,PREFNAME,PREFVAL) returns a chebfun using the preference
% PREFNAME with value specified by PREFVAL. See chebfunpref for possible
% preferences.
%
% Advanced features:
%
% CHEBFUN(F,'vectorize') wraps F in a for loop. This is useful when F
% cannot be evaluated with a vector input. CHEBFUN(F,'vectorcheck','off') 
% turns off the automatic checking for vector input.
%
% CHEBFUN(F,'scale',SCALE) constructs a chebfun with relative accuracy given 
% by SCALE.
%
% CHEBFUN(F,'trunc',N) returns an N point chebfun constructed by
% constructing the Chebyshev series at degree N-1, rather than by
% interpolation at Chebyshev points. 
%
% CHEBFUN(F,'extrapolate','on') prevents the constructor from evaluating
% the function F at the endpoints of the domain. This may also be achieved
% with CHEBFUN(F,'chebkind','1st','resampling','on') (which uses Chebyshev
% points of the 1st kind during the construction process), although this 
% functionality is still experimental.
%
% CHEBFUN(F,...,'map',{MAPNAME,MAPPARS}) allows the use of mapped Chebyshev
% expansions. See help chebfun/maps for more information.
%
% See also chebfunpref.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

classdef chebfun
    
    properties ( GetAccess = 'public', SetAccess = 'public' )
        funs = [];         % An array of the funs in the chebfun
        nfuns = 0;         % Number of funs 
        ends = [];         % List of breakpoints
        scl = 0;           % Indication of the vertical scale
        imps = [];         % Impulse (delta function) info
        trans = false;     % Row-chebfun flag
        jacobian = anon('[]','',[],1); % AD (i.e., jacobian) information
        ID = [];           % Individual ID number of chebfun - for AD
        funreturn = false; % Force functionals to return chebconsts
    end
    
    methods
        
        function f = chebfun(varargin)
            f = ctor(f,varargin{:});
        end 
        
    end
end


