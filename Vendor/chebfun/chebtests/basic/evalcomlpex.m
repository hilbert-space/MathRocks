function pass = evalcomplex
% Check that a chebfun evaluates correctly for complex arguments.
% 
% Ricardo Pachon
pts = 5;
op = @(x) sin(x)./(1+16*x.^2);
xa = -1.1; xb = 1.1; ya = -.5; yb= .5;
[xx, yy]= meshgrid(linspace(xa,xb,pts),linspace(ya,yb,pts)); 
zz = xx+1i*yy;
f = chebfun(op);
fzz = f(zz);
pass = true;
for k = 1:pts^2
    pass(k+1) = true;
    if f(zz(k)) ~= fzz(k)
        pass(k+1) = false;
    end
end

% for n = 10:10:100
%     f = chebfun(op,n);
%     fzz = f(zz);
%     err = log(abs(op(zz)-fzz));
%     contourf(xx,yy,err,log(10.^[-17:-1]),'linewidth',2);
%     caxis([log(1e-16) log(1e-1)]),
%     colormap(hot), colorbar
%     title(['n = ', num2str(n)],'fontsize',18,'fontweight','bold')
%     set(gca,'fontsize',18,'fontweight','bold')
%     drawnow, shg
% end
