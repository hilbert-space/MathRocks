function fout = jacreset(fin,newjac)
% JACRESET   Reset Jacobian of a chebfun.
%
% Chebfuns keep track of their construction in such a way that they can be
% queried for their Frechet derivative (Jacobian) with respect to any other
% chebfun using DIFF. FOUT = JACRESET(FIN) resets the Jacobian field of a
% chebfun to be empty, which will be interpreted as zero in all cases.
%
% FOUT = JACRESET(FIN,NEWJAC) sets the Jacobian to be NEWJAC, which must be
% an ANON object.
%
% FIN may be a quasimatrix.
%
% See also CHEBFUN/DIFF, ANON.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin > 1
  if ~isa(newjac,'anon')
    error('CHEBFUN:jacreset:NotAnon','New Jacobian must be an ANON object.')
  end
else
  newjac = anon('[]','',[],1);
end

fout = fin;
for funCounter = 1:numel(fin)
    fout(funCounter).jacobian = newjac;
end
