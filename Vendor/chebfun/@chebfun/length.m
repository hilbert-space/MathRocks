function len = length(f)
% LENGTH   Number of sample points used by a chebfun.
%
% LENGTH(F) is the number of sample points used by the chebfun F.
%
% If F is a quasi-matrix, LENGTH(F) is max_k{ LENGTH(F(:,k)) }.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

len = zeros(numel(f),1);

for j = 1:numel(f);
    for k = 1:f(j).nfuns
        len(j) = len(j) + f(j).funs(k).n;
    end
end

len = max(len);
