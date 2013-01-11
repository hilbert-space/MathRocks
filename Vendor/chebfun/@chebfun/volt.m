function F = volt(k,v,onevar)
% VOLT  Volterra integral operator.
% V = VOLT(K,D) constructs a chebop representing the Volterra integral
% operator with kernel K for functions in domain D=[a,b]:
%    
%      (V*v)(x) = int( K(x,y) v(y), y=a..x )
%  
% The kernel function K(x,y) should be smooth for best results.
%
% K must be defined as a function of two inputs X and Y. These may be
% scalar and vector, or they may be matrices defined by NDGRID to represent
% a tensor product of points in DxD. 
%
% VOLT(K,D,'onevar') will avoid calling K with tensor product matrices X 
% and Y. Instead, the kernel function K should interpret a call K(x) as 
% a vector x defining the tensor product grid. This format allows a 
% separable or sparse representation for increased efficiency in
% some cases.
%
% Example:
%
% To solve u(x) + x*int(exp(x-y)*u(y),y=0..x) = f(x):
% [d,x] = domain(0,2);
% V = volt(@(x,y) exp(x-y),d);  
% u = (1+diag(x)*V) \ sin(exp(3*x)); 
%
% See also fred, chebop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Require two inputs.
if nargin == 1
    error('CHEBFUN:FRED:nargin','Not enough input arguments.');
end

% Inputs in correct order. let this slide...
if isa(k,'chebfun'),  tmp = v; v = k; k = tmp; end

% Default onevar to false
if nargin==2, onevar=false; end    

% Loop for qasimatrix support
F = chebfun;
for j = 1:numel(v)
    F(j) = volt_col(k,v(j),onevar);
end

end

function F = volt_col(k,v,onevar)
    % At each x, do an adaptive quadrature.
    % Result can be resolved relative to norm(u). (For instance, if the
    % kernel is nearly zero by cancellation on the interval, don't try to
    % resolve it relative to its own scale.) 
    opt = {'resampling',false,'splitting',true,'blowup','off'};
    % Return a chebfun for integrand at any x
    v = set(v,'funreturn',0);
    dom = domain(v); d = dom.endsandbreaks; brk = d(2:end-1); 
    nrm = norm(v);
    h = @(x) chebfun(@(y) feval(v,y).*k(x,y),[d(1) brk(brk<x) x], ...
        opt{:},'scale',nrm,'exps',[0 0]);    
    F = chebfun(@(x) sum(h(x)), [d(1) brk d(end)], ...
        'exps',[0 0],'vectorize','scale',nrm);
    F.jacobian =  anon(['[Jvu nonConst] = diff(v,u,''linop'');',...
                        'der = volt(k,d)*Jvu;'],...
                        {'k','v','d','onevar'},{k,v,dom,onevar},1,'volt');
    F.ID = newIDnum;
end
  
    
  
  
  