function Fout = repmat(F,M,N) 
% REPMAT   Replicate and tile a chebfun.
%
% Fout = REPMAT(F,M,N) creates a chebfun quasimatrix Fout by tiling copies 
% of F.
%
% If F is a column quasimatrix, then REPMAT(F,1,N) returns a quasimatrix 
% with N*size(F,2) chebfun columns. If F is a row quasimatrix, 
% REPMAT(F,M,1) returns a quasimatrix with M*size(F,1).
%
% REPMAT(F,[M,N]) is the same as REPMAT(F,M,N).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin==2
  if length(M)~=2
    error('CHEBFUN:repmat:NotEnoughInputs', ...
      'Requires REPMAT(F,M,N) or REPMAT(F,[M,N]).')
  end
  N = M(2);  M = M(1);
end

Fout = chebfun;
if F(1).trans 
    if N~=1
        error('CHEBFUNchebfun:repmat:row',...
          'Use REPMAT(F,M,1) to replicate and tile row chebfuns.')
    else
        for j = 1:M, Fout = [ Fout; F ];  end
    end
else 
    if M~=1
        error('CHEBFUNchebfun:repmat:col',...
          'Use REPMAT(F,1,N) to replicate and tile column chebfuns.')
    else
        for j = 1:N, Fout = [Fout F];  end 
    end
end