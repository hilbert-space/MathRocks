function val = get(N, propName)
% GET   Get chebop properties.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

switch propName
    case {'dom','domain'}
        val = N.domain;
    case 'op'
        val = N.op;
    case 'bcs'
        val = struct('left',{N.lbcshow},'right',{N.rbcshow},'bc',{N.bcshow});
    case 'lbc'
        val = N.lbc;
    case 'rbc'
        val = N.rbc;
    case 'bc'
        val = N.bc;        
    case {'guess','init'}
        val = N.init;
    case 'dim'
        val = N.dim;
    case 'jumpinfo'
        val = N.jumpinfo;
    otherwise
        error('CHEBOP:get:propname',[propName,' is not a valid chebop property.'])
end
