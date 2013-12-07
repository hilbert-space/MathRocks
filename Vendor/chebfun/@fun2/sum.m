function S = sum(f,dim)
%SUM Definite integral of a fun2.
% 
% SUM(F) integrates over the y-variable. 
%
% SUM(F,DIM) integrate over the y-variable (DIM=1) and the x-variable
% (DIM=2). 
% 
%See also INTEGRAL2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( nargin == 1 ) % default to integrating along dim=1.
    dim = 1; 
end  


pref2 = chebfun2pref;
rect = f.map.for([-1 1], [-1 1]);
if ( norm(f.U) == 0 )
    if ( dim == 1 )
        S = chebfun(0, rect(3:4));
    else
        S = chebfun(0, rect(1:2));
    end
    return
end

if ( dim == 1 )
    % Integrate along the columns.
    if ( pref2.mode )
        cvals = sum(get(f, 'C'));
        S = transpose( (cvals.*(1./get(f, 'U'))) * get(f,'R') );
    else
        cvals = mysum(get(f,'C'),rect(3:4));
        S = transpose( (cvals.*(1./get(f, 'U'))) * get(f,'R') );
        S = chebfun(S, rect(1:2));
    end
elseif ( dim == 2 )
    % Integrate along the rows.
    if ( pref2.mode )
        rvals = sum(get(f,'R'));
        S = get(f,'C')* transpose((1./get(f, 'U')) .* transpose(rvals));
    else
        rvals = mysum(get(f,'R').', rect(1:2)).';
        S = get(f,'C')* transpose((1./get(f, 'U')) .* transpose(rvals));
        S = chebfun(S, rect(3:4)); 
    end
end

end