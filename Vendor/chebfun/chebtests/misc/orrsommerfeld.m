function pass = orrsommerfeld
% Orr-Sommerfeld eigenvalues for plane Poiseuille flow (just barely
% eigenvalue stable). Tests a fourth-order generalized eigenvalue problem,
% and the 'lr' argument of EIGS. 

tol = chebfunpref('eps');

R = 5772;
A = chebop(-1,1);
A.op = @(x,u) (diff(u,4)-2*diff(u,2)+u)/R - 2i*u - 1i*diag(1-x.^2)*(diff(u,2)-u);
B = chebop(-1,1);
B.op = @(x,u) diff(u,2) - u;
A.lbc = @(u) [u , diff(u)];
A.rbc = @(u) [u , diff(u)];

lam = eigs(A,B,10,'LR');

correct = [
     -7.819078104994955e-005-2.615676705860811e-001i
    -4.620366193293003e-002-9.534328425761246e-001i
    -4.624279708795331e-002-9.534587499934722e-001i
    -5.767171976874375e-002-3.229637183677176e-001i
    -8.298700703740958e-002-9.161327256325181e-001i
    -8.308878603034946e-002-9.162146222226847e-001i
    -1.197442736203496e-001-8.787833344958154e-001i
    -1.199267702337461e-001-8.789590506048377e-001i
    -1.548324840901456e-001-4.044151548530878e-001i
    -1.564823130376978e-001-8.413737949305676e-001i
];

err = norm( lam-correct, Inf);
pass = err < 1e-7*(tol/eps);

