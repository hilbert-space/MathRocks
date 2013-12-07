function val = get(L,propName)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

switch propName
    case 'varmat'
        val = L.varmat;
    case 'oparray'
        val = L.oparray;
    case 'difforder'
        val = L.difforder;
    case {'domain','fundomain'}
        val = L.domain;
    case 'lbc'
        val = L.lbc;        
    case 'rbc'
        val = L.rbc;
    case 'bc'
        val = L.bc;        
    case 'numbc'
        val = L.numbc;
    case 'scale'
        val = L.scale;
    case 'blocksize'
        val = L.blocksize;    
    case 'decoeffs'
        val = L.decoeffs;
    case 'ID'
        val = L.ID;
    case 'jumpinfo'
        val = L.jumpinfo;    
    otherwise
        error('CHEBFUN:linop:get:propnam',[propName,' is not a valid linop property.'])
end