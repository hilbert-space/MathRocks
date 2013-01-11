function e = end(F,k,n)
% END  Rightmost point of a chebfun's domain (or last row/col of quasimatrix).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% if n > 2
%     error('CHEBFUN:end:ngt2','Index exceeds chebfun dimensions.');
% end

if (k == 2 && ~F(1).trans) || (k == 1 && F(1).trans)
    % 'end' row/column of the quasimatrix.
    e = numel(F);
else
    % 'end' of the domain.
    e = F(1).ends(end);
end
