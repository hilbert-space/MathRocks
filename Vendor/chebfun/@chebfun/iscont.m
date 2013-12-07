function isc = iscont(F)
% ISCONT Continuity test for chebfuns.
%
% ISCONT(F) Returns logical ture if the CHEBFUN F is continuous on the
% closed interval defined by the domain of F and logical 0 otherwise.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

isc = true;
for k = 1:numel(F)
    isc = isc && contCheck(F(k));
    if ~isc
        break;
    end
end
end

function isc = contCheck(f)
% Check continuity of a Chebfun f.

isc = true;

% Delta functions.
impTol = 1e-13;
imps = f.imps;
if ( size(imps, 1) >= 2)
    if ( any(any(abs(imps(2:end, :)) > impTol)) )
        % Function with non-trivial delta functions is never continuous.
        isc = false;
        return;
    end
end

% Exponents.
expTol = 1e-13;
exps = get(f, 'exps');
if( any(any(exps < -expTol)) )
    % Function with negative exponents is never continuous.
    isc = false;
    return;
end

% Smooth chebfun.
valTol = 1e-13;
if (f.nfuns == 1)
    % Function with a single fun is always continuous.
    isc = true;    
    return;
else
    % Function has more than one fun.
    ends = f.ends;
    for i = 2:length(ends)-1        
        fLeft = feval(f, ends(i), 'left');
        fRight = feval(f, ends(i), 'right');
        fMiddle = f.imps(1, i);
        if ( any(abs([fLeft-fRight, fLeft-fMiddle, fRight-fMiddle]) > valTol) )
            isc = false;
            return;
        end        
    end    
end

end