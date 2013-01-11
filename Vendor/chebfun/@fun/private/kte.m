function [m,v] = kte(par,fh,n)
% KTE mapping strategy

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% end points
a = par(1); b = par(2);

% scale to handle arbitrary intervals
scale = @(y) ((b-a)*y+b+a)/2;
rescale = @(x) (2*x-b-a)/(b-a);
scaleder = (b-a)/2;

% non-adaptive case
if nargin == 1 || ~mappref('adapt')
    if length(par) == 2;
        alpha = .9;
    else
        alpha = par(3);
    end
    % adaptive case
else
    if n <= 33
        alpha = 0;
    else
        alpha = sech(35/n);
    end
end

% kte map
if alpha > 1e-12
    m.for = @(y) scale(asin(alpha*y)/asin(alpha));
    m.inv = @(x) sin(rescale(x)*asin(alpha))/alpha;
    m.der = @(y) (scaleder)*alpha./(asin(alpha)*sqrt(1-(alpha*y).^2));
else
    % linear map case
    m.inv = rescale;
    m.for = scale;
    m.der = @(y) scaleder;
end

% map identification
m.name = 'kte';
m.par = [a b alpha];
m.inherited = true;

% computed function values at mapped points if needed
if nargout > 1
    v = feval(fh, m.for(chebpts(n)));
end

    


