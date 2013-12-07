function val = get(f,propName)
% GET  Get fun2 properties.
%
% P = GET(F,PROP) returns the property P specified in the string PROP from
% the fun2 F. Valid entries for the string PROP are: 
%   'RANK'  -  Number of GE steps required in construction. 
%   'C'     -  The column slices of F. 
%   'U'     -  The pivot values of F. 
%   'R'     -  The row slices of a F. 
%   'MAP'   - Map(s) used by F. 
%   'PIVPOS'- Pivot locations used during construction. 
%   'DOMAIN'- The corners of the domain of F. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if numel(f) > 1
    val = cell(numel(f));
    for k = 1:numel(f)
        val{k} = get(f(k), propName);
    end
    return
end

switch propName
    case 'rank'
        val = f.rank;
    case 'C'
        val = f.C;
    case 'U'
        val = f.U;
    case 'R'
        val = f.R;
    case 'scl'
        val = f.scl;
    case 'map'
        val = f.map;
    case 'PivPos'
        val = f.PivPos;
    case 'domain'
        u=[-1,1];
        val = f.map.for(u,u);
    otherwise
        error('FUN2:get:propnam',[propName,' is not a valid fun2 property.'])
end

end