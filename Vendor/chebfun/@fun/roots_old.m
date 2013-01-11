function out = roots(g,varargin)
% ROOTS	Roots in the interval [-1,1]
% ROOTS(G) returns the roots of the FUN G in the interval [-1,1].
% ROOTS(G,'all') returns all the roots.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Default preferences
rootspref = struct('all', 0, 'recurse', 1, 'prune', 0, 'polish', chebfunpref('polishroots'));

if nargin == 2
    if isstruct(varargin{1})
        rootspref = varargin{1};
    else
        rootspref.all = true;
    end
elseif nargin > 2
    rootspref.all = varargin{1};
    rootspref.recurse = varargin{2};
end
if nargin > 3
    rootspref.prune = varargin{3};
end

r = rootsunit(g,rootspref);
if rootspref.prune && ~rootspref.recurse
    rho = sqrt(eps)^(-1/g.n);
    rho_roots = abs(r+sqrt(r.^2-1));
    rho_roots(rho_roots<1) = 1./rho_roots(rho_roots<1);
    out = r(rho_roots<=rho);
else
    out = r;
end
out = g.map.for(out);

function out = rootsunit(g,rootspref)
% Computes the roots on the unit interval

all = rootspref.all;
recurse = rootspref.recurse;
prune = rootspref.prune;
polish = rootspref.polish;

% Assume that the map in g is the identity: compute the roots in the
% interval [-1 1]!
ends = g.map.par(1:2);
g.map = linear([-1 1]);

% Update horizontal scale accordingly
if norm(ends,inf) < inf;
    g.scl.h = g.scl.h*2/diff(ends);
end

tol = 100*eps;
    
if ~recurse || (g.n<101)                          % For small length funs
    coeffs = chebpoly(g);                         % Compute Cheb coeffs
    c = coeffs;
    
    if abs(c(1)) < 1e-14*norm(c,inf) || c(1) == 0 % Remove small coeffs
        ind = find(abs(c)>1e-14*norm(c,inf),1,'first');
        if isempty(ind), out = zeros(length(c),1);
            return
        end
        c = c(ind:end);
        if length(c) < 5
            g.vals = chebpolyval(c);
            g.coeffs = c;
            g.n = length(c);
        end
    end
    
    if (g.n<=4)   % Use built-in monoial code for small funs
        r = roots(poly(g));
    else          % Assemble colleague matrix A
        c = .5*c(end:-1:2)/(-c(1));              
        c(end-1) = c(end-1)+.5;
        oh = .5*ones(length(c)-1,1);
        % Modified colleague matrix:
        A = diag(oh,1)+diag(oh,-1);
        A(end-1,end) = 1;
        A(:,1) = flipud(c);

        % Compute roots as eig(A)
        r = eig(A);                               
    end
       
    if ~all
        mask = abs(imag(r))<tol*g.scl.h;           % Filter imaginary roots
        r = real( r(mask) );
        out = sort(r(abs(r) <= 1+2*tol*g.scl.h));  % KKeep roots inside [-1 1]   
        
        % Polish
        if polish
            gout = feval(g,out);
            step = gout./feval(diff(g,1),out);
            step(isnan(step) | isinf(step)) = 0;
%             outnew = out - step;
%             mask = abs(gout) > abs(feval(g,outnew));
%             out(mask) = outnew(mask);
            out = real(out-step);
        end
        
        if ~isempty(out)
            out(1) = max(out(1),-1);                % Correct root -1
            out(end) = min(out(end),1);             % Correct root  1
        end
        
    elseif prune
        rho = sqrt(eps)^(-1/g.n);
        rho_roots = abs(r+sqrt(r.^2-1));
        rho_roots(rho_roots<1) = 1./rho_roots(rho_roots<1);
        out = r(rho_roots<=rho);
    else
        out = r;
    end
else % Recurse
    
    c = -0.004849834917525; % Arbitrary splitting point to avoid a root at c
    g1 = restrict(g,[-1 c]);
    g2 = restrict(g,[c,1]);
    out = [-1+(rootsunit(g1,rootspref)+1)*.5*(1+c);... % Find roots recursively 
        c+(rootsunit(g2,rootspref)+1)*.5*(1-c)];       %   and rescale them
end
