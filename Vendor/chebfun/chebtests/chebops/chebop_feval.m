function pass = chebop_feval
% Test various combinations of inputs to chebop/feval.
% Nick Hale, Aug 2011

%%

x = chebfun('x');
N = chebop(@(x,u,v) x+u+v);
N11 = N(x,x,x);
try
    N12 = N(x,x);
catch
    pass(1) = 1;
end
N13 = N(x,[x x]);
N14 = N([x x]);
pass(1) = pass(1) && ~norm(N11-N13) && ~norm(N13-N14);

%%

N = chebop(@(x,u) x + u(:,1) + u(:,2));
try
    N21 = N(x,x,x);
catch
    pass(2) = 1;
end
try
    N22 = N(x,x);
    pass(2) = 0;
end
N23 = N(x,[x x]);
N24 = N([x x]);
pass(2) = pass(2) && ~norm(N23-N24);

%%

N = chebop(@(x,u) x + u);
N31 = N(x,x);
pass(3) = 1;

%%

N = chebop(@(u) u(:,1) + u(:,2));
try
    N41 = N(x,x);
catch
    pass(4) = 1;
end
try
    N43 = N(x,[x x]);
    pass(4) = 0;
end
try
    N44 = N([x x]);
    pass(4) = 1;
catch
    pass(4) = 0;
end
