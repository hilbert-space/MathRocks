function pass = falknerskan
% Solves the Falkner-Skan equation and checks the result.
% Does not use Chebop. 

tol = chebfunpref('eps');
dom = domain(0,6);
beta = 0.5;

I = eye(dom); D = diff(dom);

f = @(u) diff(u,3) + u.*diff(u,2) + beta*(1-diff(u).^2);
dfdu = @(u) D^3 + diag(D^2*u) + diag(u)*D^2 - 2*beta*diag(D*u)*D;

% Initial guess satisfies u(0)=u'(0)=0, u'(dom(2))=1
u = chebfun( @(x) x.^2/(2*dom(2)), dom );

% Boundary conditions for the Newton correction
bcleft = struct('op',{I,D},'val',{0,0});
bcright = struct('op',D,'val',0);
bc = struct('left',bcleft,'right',bcright);

% Newton iteration
normdu = Inf;  niter = 0;
while normdu>1e-10*(tol/eps) && niter < 11 
  r = f(u);
  J = dfdu(u);
  J.bc = bc;
  J.scale = norm(u);
  du = -(J\r);
  u = (u+du);
  niter = niter+1;
  normdu = norm(du);
end

upp0 = 0.927680043004878;

pass = abs( feval(diff(u,2),0) -upp0) < 2e8*tol;