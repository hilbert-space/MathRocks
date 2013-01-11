function pass = cumsum_oscillate
% Compute the indefinite integral of an oscillatory function
% using CUMSUM. Compare it to the Chebfun representation of
% the exact integral using NORM.  

f = chebfun('cos(100*x)',[10 13]);
fint = chebfun('sin(100*x)/100',[10 13])-sin(1000)/100;

% real
pass(1) = norm(cumsum(f)-fint) < 1e-13*f.scl*chebfunpref('eps')/eps;

%imaginary
pass(2) = norm(cumsum(f*1i)-1i*fint,inf) < ...
    1e-13*f.scl*chebfunpref('eps')/eps;

