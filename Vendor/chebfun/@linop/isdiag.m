function isd = isdiag(A,inspect)
% ISDIAG Check for diagonal operators.
%
% ISD = ISDIAG(L) returns 1 if the linop L is a diagonal linop on its
% domain of definition, 0 otherwise. For block linops, ISD will be a 
% matrix with entries 1 or 0 corresponding to each block. 
%
% By default this information is only extracted from the L.isdiag field
% to force an inspection of the linop use the command ISDIAG(L,'inspect').

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.:

dimExpand = 10;

% We don't want to inspect, just get the flag back.
if nargin < 2 || ~strcmp(inspect,'inspect')
    isd = A.isdiag;
    return
end

% If the flag says it's zero, it definitely is!
if all(A.isdiag(:)), isd = A.isdiag; return, end

% We're going to have to get our hands dirty. Expand the linop.
Aexpand = full(feval(A,dimExpand));

% Do the inspection.
isd = A.isdiag;
for rowcounter = 1:A.blocksize(1)
    for colcounter = 1:A.blocksize(2)
        if ~A.isdiag(rowcounter,colcounter)
            Ablk = Aexpand(1+(rowcounter-1)*dimExpand:rowcounter*dimExpand, ...
                1+(colcounter-1)*dimExpand:colcounter*dimExpand);
            isd(rowcounter,colcounter) = ~any(any(Ablk-diag(diag(Ablk))));
        end
    end
end

end
