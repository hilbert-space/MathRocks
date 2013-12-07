function val = get(f, propName)
% GET   Get chebfun properties.
%
% P = GET(F,PROP) returns the property P specified in the string PROP from
% the chebfun F. Valid entries for the string PROP are:
%   'FUNS'   - Smooth components ('funs') of F.
%   'NFUNS'  - Number of piecewise components in F (i.e., numel(F.FUNS)).
%   'DOMAIN' - Endpoints of F.
%   'ENDS'   - Endpoints and breakpoints of F.
%   'IMPS'   - Values F takes at the F.ENDS.
%   'VALS'   - Values of F at Chebyshev points.
%   'POINTS' - Points at which F.VALS are stored.
%   'SCL'    - Vertical scale of F.
%   'TRANS'  - Orientation of F (i.e., column or row chebfun).
%   'EXPS'   - Exponents used for unbounded chebfuns.
%   'MAP'    - Map(s) used by F. (See "help maps")
% If F is a column (row) quasimatrix, GET will return a list of the
% requested properties for each column (row).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

val = [];

if numel(f) > 1
    val = cell(numel(f),1);
    for k = 1:numel(f)
        val{k} = get(f(k), propName);
    end
    if any(strcmp(propName,{'funreturn','trans'}))
        val = any([val{:}]);
    end
    return
end

switch propName
    case 'funs'
        val = f.funs;
    case 'map'
        if f.nfuns == 1
            val = f.funs(1).map;
        else
            val = maps(domain(f.ends));
            for k = 1:numel(f.ends)-1
                val(k) = f.funs(k).map;
            end
        end
    case 'ends'
        val = f.ends;
    case 'domain'
        val = f.ends([1 end]);        
    case 'imps'
        val = f.imps;
    case 'nfuns'
        val = f.nfuns;        
    case 'scl'
        val = f.scl;
    case {'vals','exps','points','pts','coeffs'}
        funs = f(1).funs;
        for j = 1:f(1).nfuns
            val = [val;get(funs(j),propName)];
        end
    case 'trans'
        val = f(1).trans;
    case 'funreturn'
        val = f(1).funreturn;        
    case 'jacobian'
        val = f.jacobian;
    case 'ID'
        val = f.ID;        
    case 'depth'
        val = getdepth(f.jacobian);
    otherwise
        error('CHEBFUN:get:propnam',[propName,' is not a valid chebfun property.'])
end
