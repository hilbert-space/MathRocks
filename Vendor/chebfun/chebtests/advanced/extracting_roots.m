function pass = extracting_roots
% Test extracting roots with and without maps

tol = 1e4*chebfunpref('eps');

F = @(x) cos(x);
var = {};
dd = {[-1,1] [-1 sqrt(2)]};

l = -1;
% for k = 1:2
    for j = 1:2
        for i = 1:2
            l = l+2;
            d = dd{j};

            % left root
            f = chebfun(@(x) (x-d(1)).^i.*F(x),d,var{:});
            h = f;
            h.funs(1) = extract_roots(f.funs(1));
            xx = linspace(d(1),d(2));
            pass(l) = norm(f(xx)-h(xx),inf) < tol;
            
            % right root
            f = chebfun(@(x) (d(2)-x).^i.*F(x),d,var{:});
            h = f;
            h.funs(1) = extract_roots(f.funs(1));
            xx = linspace(d(1),d(2));
            pass(l+1) = norm(f(xx)-h(xx),inf) < tol;
            
        end
    end
    var = {'map',{'kte',.99}};
% end
