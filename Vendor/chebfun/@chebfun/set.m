function F = set(F,varargin)
% SET Set chebfun properties.
% F = SET(F,PROP,VAL) modifies the property PROP of the chebfun F with
% the value VAL. PROP can be used to set:
%   'FUNS'   - The cell array of funs
%   'IMPS'   - Values F takes at the F.ENDS.
%   'SCL'    - Vertical scale of F.
%   'TRANS'  - Orientation of F (i.e., column or row chebfun).
%   'DOMAIN' - The domain of F (via a rescaling of the dependent variable).
% F = SET(F,PROP_1,VAL_1,...,PROP_n,VAL_n) modifies more than one property.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Deal with quasimatrix input.
if numel(F) > 1
%     error('CHEBFUN:set:quasi', 'Set does not support quasi-matrices.')
    for k = 1:numel(F)
        F(k) = set(F(k),varargin{:});
    end
    return
end

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
    case 'funs'
        F.funs = val;
        F.nfuns = numel(val);
        F = update_vscl(F);
    case 'nfuns'
        F.nfuns = val;    
    case 'ends'
        F.ends = reshape(val,1,numel(val));
    case 'imps'
        F.imps = val;
    case 'jacobian'
        F.jacobian = val;
    case 'funreturn'
        F.funreturn = val;        
    case 'scl'
        F.scl = val; 
        for k = 1:F.nfuns
            F.funs(k).scl.v = val;
        end
    case 'trans'
        F.trans = val;
    case 'ID'
        F.ID = val;
    case 'domain'
        old = get(F,'ends');
        if isa(val,'domain'), val = val.ends; end
        if numel(val) > 2
            warning('CHEBFUN:set:domainasgn',...
                'Can only scale. Breakpoints ignored.');
        elseif numel(val) == 1
            error('CHEBFUN:set:domainasgn2','2 vector required.');
        end
        scl = diff(val)./diff(old([1 end]));
        new = val(1)+(old-old(1))*scl;
        F.ends = new;
        for k = 1:F.nfuns
            F.funs(k) = newdomain(F.funs(k),new(k:k+1));
        end        
    otherwise
        error('CHEBFUN:set:UnknownProperty', ...
            'Chebfun properties: funs, ends, imps, scl, and trans.')
    end
end

if length(F.ends)~=F.nfuns+1 || size(F.imps,2) ~= length(F.ends)
    error('CHEBFUN:set:Inconsistent','Inconsistent chebfun.') 
end

