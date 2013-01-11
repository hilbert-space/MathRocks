function [y t] = odesol(sol)
%ODESOL  Convert an ODE solution to chebfun.
% ODESOL(SOL,OPT) converts the solution of an ODE initial-value or 
% boundary-value problem by standard MATLAB methods into a chebfun 
% representation. SOL is the one-output form of any solver such as ODE45,
% ODE15S, BVP5C, etc.
%
% The result is a piecewise chebfun of low polynomial degree on 
% each piece. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Current tolerance used by user
usertol = chebfunpref('eps'); 

ends = sol.x;
scl = max(abs(sol.y),[],2); % Vertical scale (needed for RelTol)
ncols = size(sol.y,1);

% Catch user ode preferences
opt = sol.extdata.options;

% Find relative tolerances used in computations
% start with odeset default values
RelTol = 1e-3*ones(ncols,1);           % Relative
AbsTol = 1e-6*ones(ncols,1);           % Absolute
% update if user used different tolerances
if ~isempty(opt)
    if ~isempty(opt.RelTol) % Relative tolerance given by user
        RelTol = opt.RelTol*ones(ncols,1);
    end
    if ~isempty(opt.AbsTol) % Absolute tolerance given by user
        if length(opt.AbsTol) == 1 % AbsTol might be vector or scalar
            AbsTol = opt.AbsTol*ones(ncols,1);
        else
            AbsTol = opt.AbsTol;
        end
    end   
end
% Turn AbsTol into RelTol using scale
RelTol = max(RelTol(:),AbsTol(:)./scl(:));

y = chebfun;
for j = 1:ncols
  y(:,j) = chebfun(@(x) deval(sol,x,j).', [ends(1) ends(end)],'eps', RelTol(j), 'vectorcheck',0);
end

if nargout > 1
    t = chebfun('t',domain(y(:,1)));
end

end
