function pass = chebfun2_globalopt
% Can we do global optimization? This will fail without the optimization
% toolbox.
% Alex Townsend, March 2013.

tol = chebfun2pref('eps');

Battery = {@(x,y) cos(pi*x.*y),...
    @(x,y) cos(2*pi*x.*y), ...
    @(x,y) cos(3*pi*x.*y),...
    @(x,y) cos(4*pi*x.*y),...
    @(x,y) cos(5*pi*x.*y),...
    @(x,y) cos(6*pi*x.*y),...
    @(x,y) cos(7*pi*x.*y),...
    @(x,y) sin(pi*x.*y),...
    @(x,y) cos(0*pi*(x-y).^2),...
    @(x,y) cos(pi*(x-y).^2),...
    @(x,y) cos(2*pi*(x-y).^2),...
    @(x,y) exp(sin(4*pi./(1+x)).*sin(4*pi./(1+y))),...
    @(x,y) log(1+x.*y),...
    @(x,y) cos(2*pi*x.*sin(pi*y)) + cos(2*pi*y.*sin(pi*x)),...
    @(x,y) (1-x.*y)./(1+x.^2+y.^2),...
    @(x,y) cos(pi*x.*y.^2).*cos(pi*y.*x.^2),...
    @(x,y) cos(2*pi*x.*y.^2).*cos(2*pi*y.*x.^2),...
    @(x,y) cos(3*pi*x.*y.^2).*cos(3*pi*y.*x.^2),...
    @(x,y) (x-y)./(2-x.^2+y.^2)+(y-x)./(2-y.^2+x.^2),...
    @(x,y) exp(-y.*x.^2) + exp(-x.*y.^2), ...
    @(x,y) exp((1-x.^2)./(1+y.^2)) + exp((1-y.^2)./(1+x.^2)),...
    @(x,y) 10.^(-x.*y),...
    @(x,y) 10.^(-10*x.*y),...
    @(x,y) sin(x+y)
    };

Maxi = [
    1
    1
    1
    1
    1
    1
    1
    1
    1
    1
    1
    exp(1)
    log(2)
    2
    1
    1
    1
    1
    2/3
    2
    2*exp(1)
    1
    1
    1
    ];

Mini = [
    -1
    -1
    -1
    -1
    -1
    -1
    -1
    0
    1
    -1
    -1
    exp(-1)
    0
    -2
    0
    -0.132504231754118
    -0.449023014530046
    -0.805912853597402
    0
    2*exp(-1)
    2
    10^-1
    10^-10
    0
    ];

tt=[];
for jj=1:length(Battery)
    f=Battery{jj};
    g = chebfun2(f,[0 1 0 1]);
    s=tic; [Y X] = minandmax2(g); t = toc(s);  tt = [tt t];
    pass(jj) = (norm(Y(1) - Mini(jj))<200*tol && norm(Y(2) - Maxi(jj))<1e5*tol);
end

try
    % Does the optimization toolbox exist? 
    warning('off'); % disable verbose warnings from fmincon.
    options = optimset('Display','off','TolFun', eps, 'TolX', eps);
    f = @(x,y) cos(x.*y); 
    fmincon(@(x) feval(f,x(1),x(2)),[0 0],[],[],[],[],-1,1,[],options);
    warning('on');
catch
    pass = 1;  % pass whatever if it doesn't. 
end

end