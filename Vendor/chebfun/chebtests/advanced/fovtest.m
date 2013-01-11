function pass = fovtest
% Tests the FOV (field of values) function. 
% Rodrigo Platte, Feb 2009.

A = [1 2; 3 2i];
F = fov(A);
pass1 = (abs(max(real(F))-3.049509756796393)<1e-14);

B = 7;
F = fov(B);
pass2 = (norm(abs(F-7))<1e-14);

C = diag([-1 1 1i]);
F = fov(C);
pass3 = (abs(mean(F)-.25i)<1e-14);

pass = pass1 && pass2 && pass3;
