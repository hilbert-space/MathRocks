function val = get(f,propName)
%GET   Get chebfun2 properties.
%
% P = GET(F,PROP) returns the property P specified in the string PROP from
% the chebfun F. Valid entries for the string PROP are:
%   'FUN2'   - The smooth fun2 component.
%   'NFUN2'  - Number of fun2s.
%   'DOMAIN' - Corners of the domain of F.
%   'CORNERS'- Corners of the domain of F.
%   'SCL'    - Vertical scale of F.
%   'MAP'    - Map(s) used by F. (See "help maps")
%   'COEFFS' - The bivariate Chebyshev tensor coefficients of F. 
%   'VALS'   - The values of F at a Chebyshev tensor grid. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%%
% Loop through an array of chebfun2 objects.
val = [];
if ( numel(f) > 1 )
    val = cell(numel(f));
    for ( k = 1:numel(f) )
        val{k} = get(f(k), propName);
    end
    return
end

%%
% Get the properties.

switch ( propName )
    case 'fun2'
        val = f.fun2;
    case 'nfun2'
        val = f.nfun2;
    case 'corners'
        val = f.corners;
    case 'domain'   % allow 'domain' as well as 'corners'.
        val = f.corners;
    case 'scl'
        val = f.scl;
    case 'coeffs'
        val = chebpoly2(f);
    case 'vals'
        val = chebpolyval2(f);
    otherwise
        error('CHEBFUN2:get:propnam',[propName,' is not a valid chebfun2 property.'])
end