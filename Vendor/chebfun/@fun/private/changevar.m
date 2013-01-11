function g = changevar(g)
% Change in integrand (used in sum and cumsum) for unbounded domains!

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

vends = g.vals([1,end]);
tol = chebfunpref('eps');
y = chebpts(g.n);

if isinf(g.map.par(1))
    % integral is +-inf if endpoint value isn't zero
    if abs(vends(1)) > tol*g.scl.v*1e8
        g.vals = sign(vends(1))*inf(size(g.vals));
        return
    else
        gtemp = g;
        gtemp.map = linear([-1,1]);
        dg = diff(gtemp);
        
        if norm(dg.vals(1:2),inf) < 1e-6*dg.scl.v
            g.vals(abs(g.vals) < max(10*abs(vends(1)),10*tol*g.scl.v)) = 0;
            g.vals(1) = 0;
        end
        %y(1) = -1+eps;
    end
end
if isinf(g.map.par(2))
    % integral is nan if endpoint value isn't zero
    if abs(vends(2)) > tol*g.scl.v*1e8
        g.vals = sign(vends(2))*inf(size(g.vals));
        return
    else
        gtemp = g;
        gtemp.map = linear([-1,1]);
        dg = diff(gtemp);
        
        if norm(dg.vals(end-1:end),inf) < 1e-6*dg.scl.v
            g.vals(abs(g.vals) < max(10*abs(vends(2)),10*tol*g.scl.v)) = 0;
            g.vals(end) = 0;
        end
        %y(end) = 1-eps;
    end
end
g.vals = g.vals.*g.map.der(y);
pref = chebfunpref; 
pref.extrapolate = true;
pref.eps = pref.eps*10;
g = extrapolate(g,pref,y);

% else
%
%     map = g.map;
%     g.map = linear([-1 1]);
%
%     if map.par(1) == -inf
%         for k = 1:2
%             [g,isroot] = factorfun(g,-1);
%             if ~isroot
%                 g.vals = nan.*g.vals; return
%             end
%         end
%     end
%     if map.par(2) == inf
%         for k = 1:2
%             [g,isroot] = factorfun(g,1);
%             if ~isroot
%                 g.vals = nan.*g.vals; return
%             end
%         end
%
%     end
%
%     if map.par(1) ~= -inf || map.par(2) ~= inf
%         g = g*30*map.par(3);
%     else
%         g.vals =  g.vals.*(5*map.par(3)).*(1+chebpts(g.n).^2);
%     end
%
%     g.map = map;
%
% end
%

% function [g,isroot] = factorfun(g,c,order)
% % FACTORFUN(G,C) fun factorization.
% %   FACTORFUN(G,C) returns a fun F such that, if C is a root of G, then
% %   G = (x-C).*F
% %   IF G(C) is relatively large, an error message is returned.
%
% % c must be a root of g. Here we check if c is in [-1,1].
% if abs(c)>1+1e-14*g.scl.h
%     error('FUN:factorfun:input','abs(c)>1')
% end
% isroot = true;
% if abs(feval(g,c)) > 1e+8*chebfunpref('eps')*g.scl.v
%    isroot = false;
% end
%
% % is g the zero function?
% if g.n < 2, return, end
% if nargin < 3
%     order = 1;
% end
%
% % Find closest closest node.
% x = chebpts(g.n);
% [

%% Old recurence formula
% % Chebyshev coefficients
% a = flipud(chebpoly(g)); 
% 
% % Append two zeros to vector (needed for recurence formula)
% a = [a; 0; 0];
% n = length(a);
% 
% % Need at least on linear factor
% if n<2
%     error('FUN:factorfun:input','degree must be larger than 0')
% end
% 
% % New coefficients:
% b = zeros(n-1,1);
% % Recurence relation:
% for k = n-2:-1:2
%     b(k-1) = 2*(a(k)+c*b(k)) - b(k+1);
% end
% b(1) = b(1)/2;
% 
% % Construct new fun
% g.vals = chebpolyval(flipud(b(1:n-3)));
% g.n = n-3;
% g.scl.v = max(norm(g.vals,inf),g.scl.v);
% 
% % Check accuracy and if c is really a zero of the original g:
% res = abs(a(1)-b(2)/2+c*b(1));
% if res > 1e4*chebfunpref('eps')*g.scl.h;
%     warning('FUN:factorfun:accuracy',['Results seem inacurrate -- res = ' ...
%         num2str(res)])
% end