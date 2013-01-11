function varargout = bvp5c(fun1,fun2,y0,varargin)
% BVP5C  Represent boundary-value problem solution using chebfuns.
%
% Y = BVP5C(ODEFUN,BCFUN,Y0) applies the standard BVP5C method to solve a
% boundary-value problem. ODEFUN and BCFUN are as in BVP5C. The Y0 argument
% is a chebfun that represents the initial guess to the solution Y. Its
% domain defines the domain of the problem, and the length of the chebfun
% Y0 is used to set the number of points in an initial equispaced mesh.
% Note that it is not necessary to call BVPINIT.
%
% [Y,P] = BVP5C(ODEFUN,BCFUN,Y0,PARAM,OPTS) allows you to specify an
% initial guess for any additional parameters to be found for the solution,
% and an options vector to guide the solution. See BVP5C and BVPSET for
% details. You may specify either extra argument, or both. An additional
% output is used to return the parameter values found.
%
% It is possible to take a crude continuation approach by solving for a
% simple variation of the problem, then using the resulting chebfun as the
% initial guess for a more difficult version. 
%
% Example (using built-in BVP demo functions):
%   d = [0,4];
%   x = chebfun('x',d);
%   y0 = [ x.^0, 0 ];
%   y = bvp5c(@twoode,@twobc,y0);
%   plot(y)
%
% See also bvp5c, bvpset, chebfun/bvp4c, domain/ode113

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Parse the inputs.
params = {};
opts = {};
for k = 1:nargin-3
  t = varargin{k};
  if isstruct(t)
    opts{1} = t;
  elseif isnumeric(t)
    params{1} = t;
  end
end

for k = 1:numel(y0)
    if any(get(y0(k),'exps')<0), error('CHEBFUN:bvp5c:inf',...
        'Bvp5c does not currently support functions which diverge to infinity.'); end
end
    
% Use a row quasimatrix.
if isinf(size(y0,1)), y0 = y0.'; end

% Determine the initial BVP grid from the chebfun's length.
n = 8;
for k = 1:size(y0,1)
  n = max(n,length(y0(k,:)));
end
x = linspace(domain(y0),n);  

% Call bvpinit.
f = @(x) subsref( y0, substruct('()',{':',x}) );
init = bvpinit(x,f, params{:});

% Call bvp solver and convert to chebfun.
sol = bvp5c(fun1,fun2,init,opts{:});
varargout{1} = odesol(sol,opts{:});

% Look for parameter output.
if ~isempty(params), varargout{2} = sol.parameters; end

end