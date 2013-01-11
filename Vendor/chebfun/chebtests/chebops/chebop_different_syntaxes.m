function pass = chebop_different_syntaxes
% Checks whether different allowed syntaxes for chebops work
d = [-1 1];
x = chebfun(@(x) x, d);
tol = 1e-7;

%% A call using a single chebfun
x0 = chebfun(2,d);
F  = @(u) diff(u,2);
nbc = @(u) u-1;
N = chebop( F , d , nbc , nbc , 'init' , x0 );
u = N\1;
pass(1) = norm(N(u)-1) < tol;

%% A call using x and a single chebfun
x0 = chebfun(2,d);
F  = @(x,u) diff(u,2)+x.*u;
nbc = @(u) u-1;
N = chebop( F , d , nbc , nbc , 'init' , x0 );
u = N\1;
pass(2) = norm(N(u)-1) < tol;

%% A call using x and two separate single-column chebfuns

x0 = [ chebfun(1,d) , chebfun(1,d) ];

F = @(x,u,v) [ -u + (x + 1).*v + diff(u,2) , ...
                u - (x + 1).*v + diff(v,2) ];
nbc = @(u,v) [ diff(u) , v-1 ];

N = chebop( F , d , nbc , nbc , 'init' , x0 );
u = N \ [0 0];
pass(3) = norm(N(u)) < tol;

%% A call using a quasimatrix
F = @(u) [ -u(:,1) + (x + 1).*u(:,2)+diff(u(:,1),2) , ...
            u(:,1) - (x + 1).*u(:,2)+diff(u(:,2),2) ];
nbc = @(u) [ diff(u(:,1)) , u(:,2)-1 ];
N = chebop( F , d , nbc , nbc , 'init' , x0 );
u = N \ 0;
pass(4) = norm(N(u)) < tol;

%% A call using x and a quasimatrix
F = @(x,u) [ -u(:,1) + (x + 1).*u(:,2) + diff(u(:,1),2) , ...
              u(:,1) - (x + 1).*u(:,2) + diff(u(:,2),2) ];
nbc = @(u) [ diff(u(:,1)) , u(:,2)-1 ];
N = chebop( F , d , nbc , nbc , 'init' , x0 );
u = N \ 0;
pass(5) = norm(N(u)) < tol;

%% A larger system using a quasimatrix
x0 = [ chebfun(0,d) , chebfun(0,d) , chebfun(0,d) ];
F = @(u) [ -u(:,3) + diff( u(:,1) , 2 ) , ...
            u(:,1) + diff( u(:,2) , 2 ) , ...
            u(:,2) + diff( u(:,3) , 2 )];
nbc = @(u) [ diff(u(:,1)) , u(:,2)-1 , u(:,3)-2 ];
N = chebop( F , d , nbc , nbc , 'init' , x0 );
usys = N \ 0;
pass(6) = norm(N(usys)) < tol;

%% A larger system using x and a quasimatrix
x0 = [ chebfun(0,d) , chebfun(0,d) , chebfun(0,d) ];
F = @(x,u) [ -u(:,3) + diff( u(:,1) , 2 ) , ...
            u(:,1) + diff( u(:,2) , 2 ) , ...
            u(:,2) + diff( u(:,3) , 2 )];
nbc = @(u) [ diff(u(:,1)) , u(:,2)-1 , u(:,3)-2 ];
N = chebop( F , d , nbc , nbc , 'init' , x0 );
usys = N \ 0;
pass(7) = norm(N(usys)) < tol;

%% A larger system using separate variables
x0 = [ chebfun(0,d) , chebfun(0,d) , chebfun(0,d) ];
F = @(x,u,v,w) [ -w + diff( u , 2 ) , ...
           u + diff( v , 2 ) , ...
           v + diff( w , 2 )];
nbc = @(u,v,w) [ diff(u) ,v-1 ,w-2 ];
N = chebop( F , d , nbc , nbc , 'init' , x0 );
usys = N \ 0;
pass(8) = norm(N(usys)) < tol;

