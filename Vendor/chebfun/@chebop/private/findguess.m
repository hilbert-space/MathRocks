function guess = findguess(N,fitBC)
% FINDGUESS Constructs initial guess for the solution of BVPs
%
% FINDGUESS starts by calling findNumVar which returns a (quasimatrix) of
% zero chebfun(s) with number of columns equal to the number of functions
% the operator operates on. E.g., for
%
%   N = chebop(@(x,u) diff(u,2))
%
% FINDGUESS will start by obtaining a a single zero chebfun, but for
%
%   N = chebop(@(x,u,v) [diff(u,2),diff(v,2)])
%
% it will start with a quasimatrix consisting of two zero chebfuns.
%
% If FINDGUESS is called with one argument, or with second argument FITBC =
% 1, it will proceed to modify the initial chebfun to fit linear BCs of the
% chebop N.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% If we don't pass the parameter fitBC, we assume that we want to try to
% fit to BCs. The opposite is true when we try to linearise a chebop.
if nargin == 1, fitBC = 1; end

guess = findNumVar(N);

if fitBC
    [L linBC] = linearise(N,guess);
    L = L & linBC;
    guess = fitBCs(L);
end