function pass = schrodinger_sqwell

% Tests eigs with piecewise constant coefficient, on a Schrodinger 
% wavefunction on square well potential. Exact solution computed in
% mathematica for these well parameters (unbounded domain). 

% piecewise constant potential function
d = [-40 0 6 46];         	% Domain with breakpoints 
V = chebfun({2,0,2},d);     % Potential function (square well)

% Schrodinger operator
N = chebop(@(psi) -diff(psi,2) + V.*psi, d, 0, 0);  

[Psi,E] = eigs(N,2,0);   
energies = diag(E);

% Exact on unbounded domain
lambdaMMA = [ 0.422476214321786465165559636043; 
              0.836288791108712929906950164520];   

pass = norm( sqrt(energies) - lambdaMMA ) < 1e-11;
