
function [p,q,r,mu,nu,poles,residues] = ratinterp( f , varargin )
% RATINTERP computes a robust rational interpolation or approximation.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N) computes the (M,N) rational interpolant
%   of F on the M+N+1 Chebyshev points of the second kind. F can be a Chebfun,
%   a function handle or a vector of M+N+1 data points. If F is a Chebfun, the
%   rational interpolant is constructed on the domain of F. Otherwise, the
%   domain [-1,1] is used. P and Q are Chebfuns such that P(x)./Q(x) = F(x).
%   R_HANDLE is an anonymous function evaluating the rational interpolant
%   directly.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N,NN) computes a (M,N) rational linear
%   least-squares approximant of F over the NN Chebyshev points of the second
%   kind. If NN=M+N+1 or NN=[], a rational interpolant is computed.
%
%   [P,Q,R_HANDLE] = RATINTERP(F,M,N,NN,XI) computes a (M,N) rational
%   interpolant or approximant of F over the NN nodes XI. XI can also be one
%   of the strings 'type1', 'type2', 'unitroots' or 'equidistant', in which
%   case NN of the respective nodes are created on the respective interval.
%
%   [P,Q,R_HANDLE,MU,NU] = RATINTERP(F,M,N,NN,XI,TOL) computes a robustified
%   (M,N) rational interpolant or approximant of F over the NN+1 nodes XI, in
%   which components contributing less than the relative tolerance TOL to
%   the solution are discarded. If no value of TOL is specified, a tolerance of
%   1e-14 is assumed. MU and NU are the resulting numerator and denominator
%   degrees. Note that if the degree is decreased, a rational approximation is
%   computed over the NN points. The coefficients are computed relative to the
%   orthogonal base derived from the nodes XI.
%
%   [P,Q,R_HANDLE,MU,NU,POLES,RES] = RATINTERP(F,M,N,NN,XI,TOL) returns the
%   poles POLES of the rational interpolant on the real axis as well as the
%   residues RES at those points. If any of the nodes XI lie in the complex
%   plane, the complex poles are returned as well.
%
%   [P,Q,R_HANDLE] = RATINTERP(D,F,M,N) computes the (M,N) rational interpolant
%   of F on the M+N+1 Chebyshev points of the second kind on the domain D.
%
%   See also DOMAIN/RATINTERP, CHEBFUN/INTERP1, DOMAIN/INTERP1.

%   Based on P. Gonnet,  R. Pachon, and L. N. Trefethen, "ROBUST RATIONAL
%   INTERPOLATION AND LEAST-SQUARES", Electronic Transations on Numerical
%   Analysis (ETNA), 38:146-167, 2011,
%
%   and on R. Pachon, P. Gonnet and J. van Deun, "FAST AND STABLE RATIONAL
%   INTERPOLATION IN ROOTS OF UNITY AND CHEBYSHEV POINTS", Submitted to
%   SIAM Journal on Numerical Analysis, 2011.

%   Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%   See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    % Re-direct to domain/ratinterp
    if nargout > 6
        [ p , q , r , mu , nu , poles , residues ] = ratinterp( domain(-1,1) , f , varargin{:} );
    elseif nargout > 5
        [ p , q , r , mu , nu , poles ] = ratinterp( domain(-1,1) , f , varargin{:} );
    else
        [ p , q , r , mu , nu ] = ratinterp( domain(-1,1) , f , varargin{:} );
    end
