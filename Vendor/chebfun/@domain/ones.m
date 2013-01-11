function S = ones(d,m)
% ONES  Unit chebfun.
% ONES(D,M) returns a chebfun quasimatrix with M column chebfuns that are
% identically one.
%
% ONES(M,D) returns a chebfun quasimatrix with M row chebfuns that are
% identically zero.
%
% See also DOMAIN/ZEROS, DOMAIN/EYE.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if isnumeric(d) % number given first
  s = chebfun(1,m);
  S = repmat(s.',d,1);
else
  s = chebfun(1,d);
  S = repmat(s,1,m);
end

end