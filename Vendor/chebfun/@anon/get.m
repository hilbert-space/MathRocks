function val = get(a, propName)
% GET   Get anon properties.
% P = GET(F,PROP) returns the property P specified in the string PROP from
% the anon A.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

switch propName
    case 'function'
        val = a.func;
    case 'variablesName'
        val = a.variablesName;
    case 'workspace'
        val = a.workspace;
    case 'depth'
        val = a.depth;
    case 'parent'
        val = a.parent;        
    otherwise
        error('ANON:get:propnam',[propName,' is not a valid anon property.'])
end
