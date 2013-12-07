function out = mysum(F,ends)
% Vectorised sum command for quasi-matrices.

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

[n,ignored] = size(F); %n = length(F);                                  % size of F. 
% cc = reshape(F.vals(:),n,m); 
c = chebfft(F);  
c = c(end:-1:1,:);% convert to coefficients. 
c(2:2:end,:) = 0; out = [2 0 2./(1-((2:n-1)).^2)]*c;             % integrate. 
dom = ends(1:2); 
out = ((dom(2)-dom(1))/2)*out;                 % scale to interval [a b] 
end