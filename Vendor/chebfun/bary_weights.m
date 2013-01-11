function w = bary_weights(xk)
% W = BARY_WEIGHTS(XK)
% Compute the barycentric weights W for the points XK, scaled such that
% norm(W,inf) == 1.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = length(xk);
if isreal(xk)
    C = 4/(max(xk)-min(xk)); % Capacity of interval
else
    C = 1;                   % Scaling by capacity doesn't apply for complex nodes
end

if n < 2001    && 0               % For small n using matrices is faster
   V = C*bsxfun(@minus,xk,xk.');
   V(logical(eye(n))) = 1;
   VV = exp(sum(log(abs(V))));
   w = 1./(prod(sign(V)).*VV).';
else                         % For large n use a loop
   w = ones(n,1);
   for j = 1:n
       v = C*(xk(j)-xk); v(j) = 1;
       vv = exp(sum(log(abs(v))));
       w(j) = 1./(prod(sign(v))*vv);
   end
end
% Scaling
w = w./max(abs(w));
