function varargout = chebpoly2(f)
%CHEBPOLY2 bivariate Chebyshev coefficients
%
% X = CHEBPOLY2(F) returns the matrix of bivariate coefficients such that 
% F = sum_i ( sum_j Y(i,j) T_i(y) T_j(x) ), where Y=rot90(X,2). It is
% MATLAB convention to flip the coefficients. 
%
% [A D B]=CHEBPOLY2(f) returns the same coefficients keeping them in low
% rank form, i.e., X = A * D * B'. 
%
% See also CHEBPOLYPLOT2, CHEBPOLYPLOT.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

mode = chebfun2pref('mode');  % discrete or continuous mode.

if ( isempty(f.fun2) ) % empty check
    varargout = {[], [], []}; return;
end

% zero function check
if ( norm(f.fun2.U) == 0 )
   varargout = {0, 0, 0};
   return; 
end


g=f.fun2; CC = g.C; RR = g.R; % get fun2 information. 

if ( nargout < 2 )
    % Return the matrix of coefficients
    if mode
        X = chebfft([CC.vals]) * diag(1./g.U) * chebfft([RR.vals]).';
    else
        X = chebfft(CC) * diag(1./g.U) * chebfft(RR.').';
    end
    varargout = {X}; 
elseif ( nargout == 3 )
    % Return the matrix of coefficients in low rank form.
    if ( mode )
        A = chebfft([CC.vals]); % convert columns to coefficients.
        D = diag(1./g.U);
        B = chebfft([RR.vals]).';% convert rows to coefficients.
    else
        A = chebfft(CC);
        D = diag(1./g.U);
        B = chebfft(RR.').';
    end
    varargout = {A, D, B};
else
    % Two output variables are not allowed.
    error('CHEBFUN2:CHEBPOLY2:outputs','Incorrect number of outputs'); 
end
end