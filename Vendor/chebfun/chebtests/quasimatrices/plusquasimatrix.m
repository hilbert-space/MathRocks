function pass = plusquasimatrix
% This test checks that quasimatrices of different sizes cannot be added.
% Rodrigo Platte Jun 2009


 f = chebfun('x');
 pass = false;
 try
    g = [f 2*f]+f;
 catch
     pass = true;
 end
