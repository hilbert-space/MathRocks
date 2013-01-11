function L = lagpoly(n)
% LAGPOLY   Laguerre polynomial of degree n.
% L = LAGPOLY(N) returns the chebfun corresponding to the Laguerre polynomials 
% L_N(x) on [0,inf], where N may be a vector of positive integers.
%
% Note, this is currently just a toy to play with the construction of
% Hermite polynomials using a combination of Chebfun's barycentric,
% mapping, and 'blowup' technologies. See chebfun/chebtests/unbndpolys.m
% for some testing.
%
% See also chebpoly, legpoly, jacpoly, and hermpoly.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

L = chebfun; % Empty chebfun
L(:,1) = chebfun(1,[0 inf],'exps',[0 0]);
L(:,2) = chebfun(@(x) 1-x,[0 inf],'exps',[0 1]);
for k = 2:max(n) % Recurrence relation
   L(:,k+1) = chebfun(@(x) ( (2*k-1-x).*feval(L(:,k),x)-(k-1)*feval(L(:,k-1),x) )/k,[0 inf],'exps',[0 k],2*k+2);
end

% Take only the ones we want
L = L(:,n+1);
