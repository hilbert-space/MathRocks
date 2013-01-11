function pass = chebop_fitbcs
% Create chebops, convert them to linops, and obtain chebfuns which satisfy
% BCs via fitBC

%% Simple scalar case
N = chebop(@(u) diff(u,2));
N.lbc = 1; N.rbc = 2;
L = linop(N);
u = fitBCs(L);
pass(1) = u(-1) == 1 && u(1) == 2;

%% Scalar case, breakpoints
N = chebop(@(u) diff(u,2),[-1 0 1]);
N.lbc = 1; N.rbc = 2;
L = linop(N);
u = fitBCs(L);
pass(2) = compAbs(u(-1),1) && compAbs(u(1),2) && all(u.ends == [-1 0 1]);


%% Scalar case, interior point condition
N = chebop(@(u) diff(u,2));
N.lbc = 1; N.bc = @(u) u(.5)-3;
L = linop(N);
u = fitBCs(L);
pass(3) = compAbs(u(-1),1) && compAbs(u(.5),3);

%% Scalar case, jump condition and breakpoints 
N = chebop(@(u) diff(u,2),[-1 0 1]);
N.lbc = 1; N.bc = @(u) jump(diff(u),.5)-3; N.rbc = 4;
L = linop(N);
u = fitBCs(L);
pass(4) = compAbs(u(-1),1) && compAbs(u(1),4) && ...
    compAbs(jump(diff(u),.5),3) && all(u.ends == [-1 0 .5 1]);

%% Simple system case
N = chebop(@(x,u,v) [diff(u,2)+v,u-diff(v)]);
N.lbc = @(u,v) [u-1,v-2]; N.rbc = @(u,v) u-3;
L = linop(N);
uv = fitBCs(L); u = uv(:,1); v = uv(:,2);
pass(5) = compAbs(u(-1),1) && compAbs(u(1),3) && compAbs(v(-1),2);

%% System case, breakpoints
N = chebop(@(x,u,v) [diff(u,2)+v,u-diff(v)],[0 .5 1]);
N.lbc = @(u,v) [u-1,v-2]; N.rbc = @(u,v) u-3;
L = linop(N);
uv = fitBCs(L); u = uv(:,1); v = uv(:,2);
pass(6) = compAbs(u(0),1) && compAbs(u(1),3) && compAbs(v(0),2) && all(u.ends == [0 .5 1]);

%% System case, interior point conditions
N = chebop(@(x,u,v) [diff(u,2)+v,u-diff(v)]);
N.lbc = @(u,v) [u-1,v-2]; N.bc = @(x,u,v) u(.5)-3;
L = linop(N);
uv = fitBCs(L); u = uv(:,1); v = uv(:,2);
pass(7) = compAbs(u(-1),1) && compAbs(v(-1),2) && compAbs(u(.5),3);

%% System case, jump condition and breakpoints 
N = chebop(@(x,u,v) [diff(u,2)+v,u-diff(v,2)],[-1 0 1]);
N.lbc = @(u,v) [u-1,v-2];
N.bc = @(x,u,v) [jump(u,.5)-3,jump(diff(v),-.5)-7];
L = linop(N);
uv = fitBCs(L); u = uv(:,1); v = uv(:,2);
pass(8) = compAbs(u(-1),1) && compAbs(v(-1),2) && ...
    compAbs(jump(u,.5),3) && compAbs(jump(diff(v),-.5),7) && ...
    all(u.ends == [-1 -.5 0 .5 1]);

%% Parametrised problem
N = chebop(@(x,u,v) diff(u)+(1+x).*v,[-1 1]);
N.lbc = @(u,v) u+1;
N.rbc = @(u,v) u+2;
L = linop(N);
uv = fitBCs(L); u = uv(:,1); v = uv(:,2);
pass(9) = compAbs(u(-1),-1) && compAbs(u(1),-2);


end

function p = compAbs(arg1,arg2)
% Check absolute value of difference is less than tolerance
p = abs(arg1-arg2) < 100*eps;
end