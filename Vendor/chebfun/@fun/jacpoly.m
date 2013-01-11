function jac = jacpoly(f,a,b)
% JACPOLY   Jacboi polynomial coefficients.
% A = JACPOLY(F,ALPHA,BETA) returns the coefficients such that
% F_1 = a_N P_N(x)+...+a_1 P_1(x)+a_0 P_0(x) where P_N(x) denotes the N-th
% Jacobi polynomial with paramters ALPHA and BETA, and F_1 denotes the first
% fun of chebfun F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

chebvals = get(f,'vals');
N = length(chebvals)-1;

% Chebyshev points
x = chebpts(N+1);

apb = a + b;

% Jacobi Vandermonde Matrix
P = zeros(N+1,N+1);
P(:,1) = 1;
P(:,2) = 0.5*(2*(a+1)+(apb+2)*(x-1));
for k = 2:N
    k2 = 2*k;
    k2apb = k2 + apb;
    q1 =  k2*(k + apb)*(k2apb - 2);
    q2 = (k2apb - 1)*(a*a - b*b);
    q3 = (k2apb - 2)*(k2apb - 1)*k2apb;
    q4 =  2*(k + a - 1)*(k + b - 1)*k2apb;
    P(:,k+1) = ((q2+q3*x).*P(:,k) - q4*P(:,k-1)) / q1;
end


% Solve the system
jac = P\chebvals(:);
jac = flipud(jac).';

return

disp(sprintf('forward error of Gauss elimination is %e',norm( P*jac - chebvals , inf )));

%% Pedro's slick way!

tic
chebvals = get(f,'vals');
N = length(chebvals)-1;

% Store these for the moment to check forward error
chebvals_orig = chebvals;

% Chebyshev points
x = chebpts(N+1);

% copy-paste from horder
xi = x;
ind = [ 1:N+1 ];
[ dummy , j ] = min( xi ); xi([1,j]) = xi([j,1]); 
ind([1,j]) = ind([j,1]);
[ dummy , j ] = max( xi(2:end) ); 
xi([2,j+1]) = xi([j+1,2]); 
ind([2,j+1]) = ind([j+1,2]);
p = xi - xi(1);
for k=3:N
    for i=k:N+1, p(i) = p(i) * (xi(i) - xi(k-1)); end;
    [ dummy , j ] = max( abs( p(k:end) ) ); 
    j = j + k - 1;
    xi([k,j]) = xi([j,k]); 
    p([k,j]) = p([j,k]); 
    ind([k,j]) = ind([j,k]);
    p(k:end) = p(k:end) / dummy;
end;
ind = ind(:);

% re-order nodes accoring to Higham
x = x(ind); 
chebvals = chebvals(ind);
rind = [0:N]; 
rind = rind(ind);

apb = a + b;

% init the three-term recursion arrays
alfa = zeros(N+1,1);
beta = zeros(N+1,1);
gama = zeros(N+1,1);

% Recurrence coefficients
alfa(1) = 2 / ( apb + 2 ); 
beta(1) = (2*a - apb) / (apb + 2);
for k = 2:N+1
    k2 = 2*k;
    k2apb = k2 + apb;   
    q1 =  k2*(k + apb)*(k2apb - 2);
    q2 = (k2apb - 1)*(a*a - b*b);
    q3 = (k2apb - 2)*(k2apb - 1)*k2apb;
    q4 =  2*(k + a - 1)*(k + b - 1)*k2apb;
    alfa(k) = q1 / q3; 
    beta(k) = q2 / q3; 
    gama(k) = q4 / q3;
end

% do the coeffs_incr-thing!
c = coeffs_incr( x , chebvals , alfa , beta , gama );
toc

disp(sprintf('forward error of coeffs_incr is %e',norm( P*c - chebvals_orig , inf )));
disp(sprintf('||jac-c||_inf is %e',norm(jac-c,inf)));

jac = flipud(jac).';


function c = coeffs_incr ( x , fx , alfa , beta , gama )

% move the max and min of x to the front
% x_avg = sum(x)/length(x);
% [ dummy , ind ] = sort( -abs( x - x_avg ) );
% x = x(ind); fx = fx(ind);

% init some stuff
n = length(x)-1;
c = [ fx(1) ]';
eta = [ -x(1) - beta(1) , alfa(1) ]';
eta_new = zeros(n+1,1);
v = zeros(1,n+1);

% main loop
for i=2:length(x)
    
    % compute g_i and pi_i
    v(1) = 1; v(2) = ( x(i) + beta(1) ) / alfa(1);
    for j=3:i
        v(j) = ((x(i) + beta(j-1))*v(j-1) - gama(j-1)*v(j-2) ) / alfa(j-1);
    end;
    g_i = v(1:i-1) * c;
    pi_i = v(1:i) * eta;
    % disp([ g_i , max(abs(c)) , pi_i , max(abs(eta)) ]);
    
    % compute g_i and pi_i using the clenshaw algorithm
    % g(i) = 0; g(i-1) = c(i-1);
    % p(i) = eta(i); p(i-1) = 2*x(i)*p(i) + eta(i-1);
    % for j=i-2:-1:2
    %     g(j) = 2*x(i)*g(j+1) + c(j) - g(j+2);
    %     p(j) = 2*x(i)*p(j+1) + eta(j) - p(j+2);
    % end;
    % if i > 2
    %     g(1) = x(i)*g(2) + c(1) - g(3);
    %     p(1) = x(i)*p(2) + eta(1) - p(3);
    % end;
    % g_i = g(1); pi_i = p(1);
    % disp([ g_i , pi_i ; g(1) , p(1) ]);
    
    % compute a_i
    a_i = (fx(i) - g_i) / pi_i;
    % disp([ (fx(i) - g_i) / max(abs(fx(i)),abs(g_i)) ]);
    % disp( max(abs(c)) / g_i );
    
    % update c
    c = [ c + a_i * eta(1:i-1) ; a_i * eta(i) ];
    % disp([ max(abs(eta)) , max(abs(c)) ]);
    
    % update eta (old school)
    % T = [ diag(alfa(1:end-1),-1) - diag(x(i)+beta) + diag(gama(2:end),1) ; zeros(1,length(alfa)-1) alfa(end) ];
    % eta = T(1:i+1,1:i) * eta;
    
    % update eta
    eta_new(i+1) = eta(i) * alfa(i);
    eta_new(i)   = eta(i-1) * alfa(i-1) - eta(i) * (x(i) + beta(i));
    for j=2:i-1
        eta_new(j) = eta(j-1)*alfa(j-1) - eta(j)*(x(i) + beta(j)) + eta(j+1)*gama(j+1);
    end;
    eta_new(1) = -eta(1)*(x(i) + beta(1)) + eta(2)*gama(2);
    eta = eta_new(1:i+1) / max(abs(eta));
    
    % plot whatever we have up to here
    % xx = linspace(min(x),max(x),200)';
    % V = [ ones(200,1) , xx ];
    % for j=3:i+1
    %     V(:,j) = ((xx + beta(j-1)).*V(:,j-1) - gama(j-1)*V(:,j-2) ) / alfa(j-1);
    % end;
    % plot(xx,V*eta,'-r',xx,V(:,1:i)*c,'-g',x,fx,'ob'); pause;
    
end;

