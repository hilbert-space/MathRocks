function Fout = airy(K,F)
% AIRY   Airy function of a chebfun.
% 
% AIRY(F) returns the Airy function of a chebfun F. 
% AIRY(K,F) uses the parameter K as in the standard MATLAB command AIRY to 
% compute different results based on the Airy function

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1, 
    F = K;
    K = 0;
end

Fout = comp(F, @(x) real(airy(K,x)));  
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1=diag(airy(K+1,F));der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F' 'K'},{F(k) K},1,'airy');
    Fout(k).ID = newIDnum();
end
