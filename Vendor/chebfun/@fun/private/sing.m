function m = sing(pars)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

ends = pars(1:2);
default_pow = .25;

if length(pars) == 2
    pow = [default_pow default_pow];
elseif length(pars) > 2
    pow = pars(3:end);
end

if length(pow)==1, 
    error('FUN:SING:numin','Singmap requires two-vector of singularities')
end

pow(~pow) = 1;

pos = 0;
for k = 1:2
    if pow(k)~=1 && pow(k)~=0
        pos = pos+(-1)^k;
    elseif isnan(pow(k))
        pow(k) = default_pow;
    end
end

L = linear(ends);

% the map is linear
if ~pos && all(pow == 1)
    m = L;
    m.name = 'sing';
    m.par = [ends pow]; 
    m.inherited = true;
    return
end

% Can only do .25 powers at boths ends (or maybe .5?)
if ~pos && (~all(pow==.25) && ~all(pow==.5))
    pow = [.25 .25];
%     warning('FUN:sing:bothends',['Singmaps at boths ends may only have ', ...
%     'parameters 0.25']);
end
    
powi = 1./pow;

switch pos
       
    case -1 % Left point singularity
        powi = powi(1);
        m.for = @(y) L.for( 2*( .5*(y+1) ).^powi - 1 );
%         m.der = @(y) L.der(1) * 2 * powi * ( .5*(y+1) ).^(powi-1);
        m.inv = @(x) 2*( .5*(L.inv(x)+1) ).^pow(1) - 1;
        m.der = @(y) L.der(1) * 1 * powi * ( .5*(y+1) ).^(powi-1);
    case 1 % Right point singularity
        powi = powi(2);
        m.for = @(y) L.for( 1 - 2*( .5*(1-y) ).^powi);
%         m.der = @(y) -L.der(1) * 2 * powi * ( .5*(1-y) ).^(powi-1);
        m.inv = @(x) 1 - 2*( .5*(1-L.inv(x)) ).^pow(2);
        m.der = @(y) L.der(1) * 1 * powi * ( .5*(1-y) ).^(powi-1);
    case 0 % Both points sigularities
        if all(pow(1) == .5)
            m.for = @(y) L.for(sin(pi/2*y));
            m.inv = @(x) 2/pi*asin(L.inv(x));
            m.der = @(y) L.der(1)*(pi/2)*cos(pi/2*y);
        else
            m.for = @(y) L.for(sin(pi/2*sin(pi/2*y)));
            m.inv = @(x) 2/pi*asin(2/pi*asin(L.inv(x)));
            m.der = @(y) L.der(1)*(1/4)*cos((1/2)*pi*sin((1/2)*pi*y)).*pi^2.*cos((1/2)*pi*y);
        end
end

m.name = 'sing';
m.par = [ends pow]; 
m.inherited = true;