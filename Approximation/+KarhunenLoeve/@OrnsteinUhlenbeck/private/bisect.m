function r = bisect(xL,xR,f)
tol = 1e-10;
x0 = 0.5*(xR+xL);
while(abs(f(x0))>tol)
    if(f(x0)*f(xL)<0)
        xR = x0;
    else
        xL = x0;
    end
    x0 = 0.5*(xL+xR);
    %f(x0)
end
r = x0;