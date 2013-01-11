function [ x , fval , exitflag ] = fzero( f , x0 , options )
% FZERO  Find a single root of a chebfun.
%
% This function is a wrapper for chebfun/roots.
%
% X = FZERO(F,X0) returns the real root of the chebfun F nearest to X0 if it
% is a scalar or the first real root in the interval defined by
% XO if it is a vector of length two.
%
% [X,FVAL,EXITFLAG] = FZERO(F,X0,OPTIONS) sets FVAL to the value of F at
% the root X. All OPTIONS are ignored. EXITFLAG is set to one of the
% following exit conditions:
%
%    1  FZERO found a zero X.
%    -6  FZERO could not find a root in the interval.
%
% Note that FZERO will only look for roots on the real line. To find
% complex roots, use chebfun/roots.
%
% See also chebfun, chebfun/roots.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    % Check the inputs
    [ a , b ] = domain( f );
    if length(x0) == 1
        if ( x0 < a ) || ( x0 > b )
            error( 'CHEBFUN:fzer:x0' , [ 'The requested point is outside of the ' ...
                'domain over which this chebfun is defined.' ] );
        end
    elseif length(x0) == 2
        if ( x0(1) < a ) || ( x0(2) > b )
            error( 'CHEBFUN:fzer:x0' , [ 'The requested interval is not within the ' ...
                'domain over which this chebfun is defined.' ] );
        end
    else
        error( 'CHEBFUN:fzer:x0' , [ 'The argument x0 should be either a scalar ' ...
            'or a vector of length 2.' ] );
    end
    
    % Get the (real) roots of f
    if length(f) > 100 && length(x0) == 2
        f = f{ x0(1) , x0(2) };
    end
    r = roots( f );

    % Grab the first root closest to x0.
    if isempty( r )
        x = [];
        fval = [];
        exitflag = -6;
    else
        [ dummy , ind ] = min( abs( r - x0(1) ) );
        x = r( ind );
        fval = feval( f , x );
        exitflag = 1;
    end
