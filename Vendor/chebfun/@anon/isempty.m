function tf = isempty(a)
% ISEMPTY True for empty anon.
%    ISEMPTY(A) returns 1 if A is an empty anon and 0 otherwise. An
%    empty anon has no variablesName.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
tf =  isempty(a.variablesName);