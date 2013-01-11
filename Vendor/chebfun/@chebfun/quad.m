function [ q , fcnt ] = quad( f , a , b , tol , trace )
% QUAD   Numerically evaluate the integral of a chebfun over an interval.
%
% This function is a wrapper for chebfun/sum.
%
% Q = QUAD(F,A,B) evaluates the integral of the chebfun F over the interval
% [A,B] using chebfun/sum.
%
% [Q,FCNT] = QUAD(F,A,B,TOL,TRACE) The arguments TOL and TRACE are ignored,
% as the integral is evaluated to full accuracy in one single step. The number
% of function evaluations FCNT is set to the length of F.
%
% To use the original QUAD on a chebfun, you can bypass this overloaded
% function by wrapping it in an anonymous function:
%
%     Q = quad( @(x) f(x) , a , b , tol );
%
% See also QUAD, QUADL, QUADGK.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    % Check if user suplied a tolerance or trace.
    if nargin > 3
        warning( 'CHEBFUN:quad:tol' , [ 'This is a wrapper for chebfun/sum ' ...
            'and the argument ''tol'' will be ignored as the result is accurate ' ...
            'to the tolerance used to construct the chebfun ''f'' (see ' ...
            'chebfunpref(''eps'')).' ] );
    end
    if nargin > 4
        warning( 'CHEBFUN:quad:trace' , [ 'This is a wrapper for chebfun/sum ' ...
            'and the argument ''trace'' will be ignored as the result is ' ...
            'evaluated in a single step.' ] );
    end
    
    % Check if [a,b] is within the domain of the chebfun.
    [ af , bf ] = domain( f );
    if ( a < af ) || ( b > bf )
        error( 'CHEBFUN:quad:ab' , [ 'The requested interval is outside of the ' ...
            'domain over which this chebfun is defined.' ] );
    end

    % Compute the quadrature, set the return values
    q = sum( f , a , b );
    fcnt = length( f );
