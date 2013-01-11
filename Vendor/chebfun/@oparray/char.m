function s = char(A)
% CHAR   Convert oparray to pretty-printed string.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(A)
  s = '{}';
elseif numel(A.op)==1
  s = char(A.op{1,1});
else
  s = '';
  for i = 1:size(A.op,1)
    sr = '';
    for j = 1:size(A.op,2)
      s1 = char(A.op{i,j});
      sr = [sr sprintf('%-22s',s1)];
    end
    s = char(s,sr);
  end
  if all(s(1,:)==' '), s(1,:) = []; end
end

end