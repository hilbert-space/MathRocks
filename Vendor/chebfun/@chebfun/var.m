function out = var(F)
% VAR   Variance.
% VAR(F) is the variance of the chebfun F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if F(1).trans
    out = transpose(var(transpose(F)));
else
    if ~isempty(F) && F(1).funreturn
        out = chebconst;
    else
        out = zeros(1,size(F,2));
    end
    for k = 1:size(F,2)
        Y = F(:,k)-mean(F(:,k));
        out(k) = mean(Y.*conj(Y));
    end
end

