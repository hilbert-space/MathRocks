function f = flipud(f,newends)
% FLIPUD Flip/reverse a fun.
%
% G = FLIPUD(F) returns a fun G with domain [a b] such that G(x) = F(b+a-x) 
% for all x in [a b], where [a b] is the domain of F. If [a b] is symmetric
% about 0, this means that G(x) = F(-x).
%
% G = FLIPUD(F,[C D]) both flips and translates F so that G has domain 
% [C D]. Theoretially this should require (D-C) = (b-a), but this is not
% enforced.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% grab the ends
ends = f.map.par(1:2);
a = ends(1); b = ends(2); 

% these should be finite
if any(isinf(ends))
    error('FUN:flipud:unbounded',...
        'FLIPUD cannot be used on unbounded domains');
end
if nargin > 1
    if any(isinf(newends))
        error('FUN:flipud:unbounded',...
            'FLIPUD cannot be used on unbounded domains');
    end
    % new ends have been passed
    c = newends(1); d = newends(2);
else
    % by default, simply flip domain
    c = ends(1); d = ends(2);
end

% flip the values, coeffs, and exps
f.vals = flipud(f.vals);
f.coeffs(end-1:-2:1) = -f.coeffs(end-1:-2:1); % negate odd coeffs
f.exps = fliplr(f.exps);

% HMP;SJGR (AKA, 'deal with maps')
m = f.map;                                    % grab the map
if strcmp(m.name,'linear') % for linear map, simply create a new one
    m = struct('for',@(y) d*(y+1)/2+c*(1-y)/2, ...
               'inv',@(x) (x-c)/(d-c)-(d-x)/(d-c), ...
               'der',@(y) (d-c)/2 + 0*y,'name','linear','par',[c d], ...
               'inherited',true) ;
else         
    m.for = @(y) (d-c)*(b-m.for(-y))/(b-a)+c; % flip the forward map
    m.der = @(y) (d-c)/(b-a)*m.der(-y);       % derivative is easy
    if isfield(m,'inv') && ~isempty(m.inv)    % inverse not always present
        lininv = @(x) ((b-a)*x+a*(d-c)-c*(b-a))/(d-c); % inverse
        m.inv = @(x) m.inv(lininv(x));
    end  
    m.par(1:2) = [c d];                       % update the ends 
end
f.map = m;                                    % update the map
