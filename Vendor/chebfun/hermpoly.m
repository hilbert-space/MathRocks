function H = hermpoly(n,type)
% HERMPOLY   Hermite polynomial of degree n.
% H = HERMPOLY(N) returns the chebfun corresponding to the 'physicist'-type 
% Hermite polynomials H_N(x) on [-inf,inf] (orthogonal with respect to the 
% weight exp(-x.^2)), where N may be a vector of positive integers.
%
% H = HERMPOLY(N,'PROB') normalises instead by the probablist's definition
% (with weight exp(-x.^2/2)), which gives rise to monic polynomials.
%
% Note, this is currently just a toy to play with the construction of
% Hermite polynomials using a combination of Chebfun's barycentric,
% mapping, and 'blowup' technologies. See chebfun/chebtests/unbndpolys.m
% for some testing.
%
% See also chebpoly, legpoly, jacpoly, and lagpoly.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1
    % By default we take the physicist's definition
    type = 'phys';
end

if strcmpi(type,'prob')
    normtype = 1;
else
    normtype = 2;
end

H = chebfun(1,[-inf inf],'exps',[0 0]);
if normtype == 1     % Probabilist type
    H(:,2) = chebfun(@(x) x,[-inf inf],'exps',[1 1]);
    for k = 2:max(n) % Recurrence relation
       H(:,k+1) = chebfun(@(x) (x.*feval(H(:,k),x)-(k-1)*feval(H(:,k-1),x)),[-inf inf],'exps',[k k],2*(k+2));
    end
else                 % Physicist type
    H(:,2) = chebfun(@(x) 2*x,[-inf inf],'exps',[1 1]);
    for k = 2:max(n) % Recurrence relation
       H(:,k+1) = chebfun(@(x) (2*x.*feval(H(:,k),x)-2*(k-1)*feval(H(:,k-1),x)),[-inf inf],'exps',[k k],2*(k+2));
    end
end

% Take only the ones we want
H = H(:,n+1);


