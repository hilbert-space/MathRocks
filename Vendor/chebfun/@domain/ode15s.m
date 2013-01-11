function [t,y] = ode15s(varargin)
%ODE15S  Represent initial-value problem solution using chebfuns.
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
% domain class signals Matlab to use the chebfun version of ODE15S rather 
% than the standard version.
%
% Example:
%   y = ode15s(@vdp1000,domain(0,3000),[2;0]); % solve Van der Pol problem
%   roots( y(:,1)-1 );   % find times when first component is 1
%
% See also ode15s, odeset, domain/ode113, domain/ode45

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Convert domain to 2-vector of endpoints.
j = find( cellfun('isclass',varargin,'domain') );
varargin{j} = varargin{j}.ends;

[y t] = odesol( ode15s(varargin{:}) ); 

% Check if the ode function was called with 1 or 2 arguments. If 1 argument
% was used, we only want to return the solution y, if 2 arguments were used
% we both want to return t and y. Note however that to agree with common use
% of the ode functions in Matlab, we have to assume that the function is
% called with [t,y] instead of [y,t]. If only one argument is used, we
% therefore have to switch the name of the variables t and y in order to
% return the solution correctly.
if nargout == 1
    t = y; % As only t will be returned in this case
end

end
