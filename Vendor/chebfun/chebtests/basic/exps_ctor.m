function pass = exps_ctor
% Tests construction with exps
% Nick Hale, Nov 2009

tol = chebfunpref('eps');

F = @(x) sin(10*x);
    
for k = 1:3
    
    M = 1e12;
    exps = floor(M*randn(1,2))/M;
    ends = sort(randn(1,2));
    
    f = chebfun(@(x) F(x).*(-ends(1)+x).^exps(1).*(ends(2)-x).^exps(2),ends,'exps',[exps(1) exps(2)]);
    g = chebfun(F,ends);

    f.funs(1) = setexps(f.funs(1),[0 0]); 
    f.imps = [f.vals(1) f.vals(end)];
    
    pass(k) = norm(f-g,inf) < 500*tol;
end





