function u = pde15s(N, t, varargin)
%PDE15S    Basic PDE solver for chebops.
% PDE15S(N,T) solves the PDE u_t = N.op(u,t,x) where N is a chebop with
% the initial condition given by N.init. See CHEBFUN/PDE15S for more
% detailed information.
%
% PDE15S(N, T, OPTS) allows extra input options defined by OPTS = PDESET
%
% Example 1: Nonlinear Advection
%   d = [-1 1];
%   [N x] = chebop(d);
%   N.op = @(u,t,x,D) -(1+0.6*sin(pi*x)).*D(u);
%   N.init = exp(3*sin(pi*x));
%   N.bc = 'periodic';
%   u = pde15s(N,0:.05:3);
%   surf(u,0:.05:3)
%
% Example 2: Kuramoto-Sivashinsky
%   d = [-1 1];
%   [N x] = chebop(d);
%   N.op = @(u,D) u.*D(u)-D(u,2)-0.006*D(u,4);
%   N.init = 1 + 0.5*exp(-40*x.^2);
%   N.lbc = struct('op',{'dirichlet','neumann'},'val',{1,2});
%   N.rbc = struct('op',{'dirichlet','neumann'},'val',{1,2});  
%   u = pde15s(N,0:.01:.5);
%   surf(u,0:.01:.5)
%
% Example 3: Chemical reaction (system)
%   d = [-1 1];
%   [N x] = chebop(d);
%   N.init = [ 1-erf(10*(x+0.7)) , 1 + erf(10*(x-0.7)) , chebfun(0,d) ];
%   N.op = @(u,v,w,diff)  [ 0.1*diff(u,2) - 100*u.*v , ...
%                      0.2*diff(v,2) - 100*u.*v , ...
%                     .001*diff(w,2) + 2*100*u.*v ];
%   N.lbc = 'neumann';     
%   N.rbc = 'neumann';     
%   uu = pde15s(N,0:.1:3);
%   mesh(uu{3})
%
% See also chebfun/pde15s, pdeset

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if strcmpi(N.lbc,'periodic') || strcmpi(N.rbc,'periodic'), 
    bc = 'periodic';
else
    if strcmpi(N.lbcshow,'dirichlet') || strcmpi(N.lbcshow,'neumann')
        N.lbc = N.lbcshow;
    end
    bc.left = N.lbc;
    if strcmpi(N.rbcshow,'dirichlet') || strcmpi(N.rbcshow,'neumann')
        N.rbc = N.rbcshow;
    end
    bc.right = N.rbc;
end

if nargin > 2
    v1 = varargin{1};
    if strcmpi(v1,'dirichlet')
        bc = 'dirichlet';
        varargin(1) = [];
    elseif strcmpi(v1,'neumann')
        bc = 'neumann';
        varargin(1) = [];
    elseif strcmpi(v1,'periodic')
        bc = 'periodic';
        varargin(1) = [];
    end
end

% Some basic error catching
if isempty(N.init)
    error('CHEBFUN:chebop:pde15:init','Initial condition is empty.');
elseif isempty(N.op)
    error('CHEBFUN:chebop:pde15:op','PDE RHS (N.op) is empty.');
elseif isa(N.op,'linop')
    error('CHEBFUN:chebop:pde15:linop','PDE15 does not support linops.');
end

% Ensure initial guess is a chebfun
if ~isa(N.init,'chebfun')
    init = [];
    for k = 1:numel(init)
        init = chebfun(N.init(k),N.domain);
    end
    N.init = init;
end

% Pass to chebfun/pde15s
u = pde15s( N.op, t, N.init, bc, varargin{:} );

