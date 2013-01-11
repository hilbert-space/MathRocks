function u = fraccalc(u,alpha)
% FRACCALC Fractional calculus of a chebfun
%  FRANCCALC(U,N) is called by DIFF(U,N) and CUMSUM(U,N) when N is not an
%  integer and computes the fractional integral of order ALPHA
%  (as defined by the Riemann–Liouville integral) of the chebfun U.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(u)
    u(:,k) = fracintcol(u(:,k),alpha);
end

end

function v = fracintcol(u,alpha)

% Deal with integer parts
for k = 1:alpha
    u = cumsum(u);
end

% Just the fractional part is left
alpha = alpha - floor(alpha);

if alpha == 0 % Nothing to do
    v = u;
    return
end

% get ends
ends = get(u,'ends');

% ua = feval(u,ends(1));
% if abs(ua) > u.scl*chebfunpref('eps')
%     warning('CHEBFUN:fracint:zeros', ...
%         'FRACINT and FRACDER assume the chebfun is zero at the left boundary.');
% end

% Get the exponents of u
exps = get(u,'exps');
% fractional kernel
k = @(x,s) (x-s).^(alpha-1);

    % integrand of the operator
    function y = h(x)
        if any(x == ends(1))
            y = chebfun(0,[ends(1),ends(1)]);
        elseif any(x == ends(2:end))
            y = chebfun(NaN,[ends(1),x]);
        else
%             y = chebfun(@(s) feval(u,s).*k(x,s),[ends(ends<x) x],'exps',[exps(1) alpha-1],'scale',u.scl) 
            
            % playing with piecewise chebfuns  
            newends = [ends(ends<x) x];
            tmpexps = [];
            for l = 1:length(newends)-1
                tmpexps = [tmpexps exps(l,1) 0];
            end
            tmpexps(end) = alpha-1;
            y = chebfun(@(s) feval(u,s).*k(x,s),newends,'exps',tmpexps,'scale',u.scl,'extrapolate',true);

        end
    end

newexps = exps;
newexps(1) = exps(1)+alpha;
newends = ends;

% the result
v = 1./gamma(alpha)*chebfun(@(x) sum(h(x)), newends ,'vectorize','exps',newexps);

% diff data
v.jacobian = anon('der1=diff(domain(f),n); der2 = diff(f,u); der = der1*der2; nonConst = ~der2.iszero;',{'f' 'n'},{u alpha},1);
v.ID = newIDnum;

if newexps(1) < 0
    v.funs(1) = extract_roots(v.funs(1));
end

end