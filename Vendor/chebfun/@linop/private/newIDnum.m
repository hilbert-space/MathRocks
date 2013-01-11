function newID = newIDnum()

% Mechanism for giving ops unique IDs. These are used to store
% realizations and LU factors. Technically, the method could fail if this
% function is cleared (erasing persistent storage) while the chebop methods
% are left uncleared, but this possibility seems remote.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

persistent ID
if isempty(ID), ID = 0; end
ID = ID+1;
newID = ID;

end
