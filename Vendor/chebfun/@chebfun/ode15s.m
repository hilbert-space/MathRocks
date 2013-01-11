% ODE15S   Represent initial-value problem solution using chebfuns.
%
% Y = ODE15S(ODEFUN,D,...) applies the standard ODE15S method to solve an
% initial-value problem on the domain D. The result is then converted to a
% piecewise-defined chebfun or quasimatrix with one column per solution 
% component.
%
% One can also write [T,Y] = ODE15S(...).
%
% CHEBFUN/ODE15S has the same calling sequence as Matlab's standard ODE15S, 
% except that instead of a TSPAN vector like  [T0 TFINAL], it takes a TSPAN
% domain like domain(T0,TFINAL). The presence of this argument from the 
% domain class signals Matlab to use the Chebfun version of ODE15S rather 
% than the standard version.
%
% Example:
%   y = ode15s(@vdp1000,domain(0,3000),[2;0]); % solve Van der Pol problem
%   roots( y(:,1)-1 );   % find times when first component is 1
%
% See also ODE15S, ODESET, DOMAIN/ODE113, DOMAIN/ODE45.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This is a dummy file. The actual code is under @domain.
