function g = set(g,varargin)
% SET Set fun properties.
% G = SET(G,PROP,VAL) modifies the property PROP of the fun G with
% the value VAL. PROP can be 'vals', 'n', 'scl', 'scl.h', or 'scl.v'.
%
% G = SET(G,PROP_1,VAL_1,...,PROP_n,VAL_n) modifies more than one property.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'vals'
            g.vals = val;
            g.n = length(val);
            g.scl.v = max( g.scl.v, norm(val, inf) );
            g.coeffs = [];
        case 'coeffs'
            g.coeffs = val;
        case 'n'
            g.n = val;
        case 'scl'
            g.scl = val;
        case 'scl.h'
            g.scl.h = val;
        case 'scl.v'
            for k=1:numel(g)
                g(k).scl.v = val;
            end
        case 'map'
            g.map = val;
        case 'exps'
            g.exps = val;
        otherwise
            error('FUN:set:badprop','fun properties: val, n, map, exps, or scl')
    end
end