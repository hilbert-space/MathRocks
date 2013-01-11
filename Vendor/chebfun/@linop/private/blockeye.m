function B = blockeye(dom,m)
% Block identity operator of size m by m.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Z = zeros(dom);  
I = eye(dom);
B = linop();

for i = 1:m
  G = linop();
  for j = 1:i-1
    G = [G Z];
  end
  G = [G I];
  for j = i+1:m
    G = [ G Z ];
  end
  B = [B; G];
end

end
