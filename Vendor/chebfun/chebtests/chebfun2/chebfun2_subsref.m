function pass = chebfun2_subsref
% Subsref check for chebfun2 objects. 
% Alex Townsend, March 2013. 


pass = 1;
f = @(x,y) cos(x); g=chebfun2(f);  % any fun2.
c = chebfun(f);
try
    % subrefs working with single reference
    fsub = g.fun2;
    % get working
    fget = get(g,'fun2');
    % hard code subreferencing. Take one dimension slices. 
    pass(1) = (norm(g(:,pi/6)-c)<1e-14);
    pass(2) = (norm(g(pi/6,:)-f(pi/6,pi/6))<1e-14);

    pass = all(pass); 
catch
    pass = 0;
end
end