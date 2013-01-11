function F = conj(F)
% CONJ	 Complex conjugate.
% 
% CONJ(F) is the complex conjugate of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    funs = F(k).funs;
    for j = 1:numel(funs)
        funs(j) = conj(funs(j));
    end
    F(k).funs = funs;
    F(k).imps = conj(F(k).imps);
    
%     F(k).jacobian = anon('diag1 = diag(conj(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1);
%     F(k).jacobian = anon(['diag1 = diag(real(F)); ',...
%                           'der1 = diff(real(F),u,''linop''); ',...
%                           'diag2 = diag(imag(F)); ',...
%                           'der2 = diff(imag(F),u,''linop''); ',...
%                           'der = diag1*der1+diag2*der2; ',...
%                           'nonConst = ~der1.iszero & ~der2.iszero;'],...
%                           {'F'},{F(k)},1);
%     F(k).ID = newIDnum();
end
