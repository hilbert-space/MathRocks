function f = power(f,n)
%.^	Chebfun2 power.
%
% F.^G returns a chebfun2 F to the scalar power G, a scalar F to the
% chebfun2 power G, or a chebfun2 F to the chebfun2 power G.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isa (f,'double') )                % double.^chebfun2
    if isempty(n) % check for empty chebfun2.
        f=n;
        return;
    end
    op = @(x,y) f.^(n.feval(x,y));
    f = chebfun2(op, n.corners);
    
elseif ( isa (n,'double') )            % chebfun2.^double
    if isempty(f) % check for empty chebfun2.
        return;
    end
    if ( abs(round(n) - n) > eps )
        % positive/negative test.
        [bol wzero] = singlesigntest(f);
        if ( bol == 0 || wzero == 1 ) 
            error('CHEBFUN2:POWER:FRACTIONAL','A change of sign/zero has been detected, unable to represent the result.');
        end
    end
    op = @(x,y) f.feval(x,y).^n;
    f = chebfun2(op, f.corners);
else                                  % chebfun2.^chebfun2
    if (~all(f.corners == n.corners )) % check they're on the same domain.
        error('CHEBFUN2:power:domain','Domains must be the same');
    end
    if ( isempty(n) ) % check for empty chebfun2.
        f=n;
        return;
    end
    if (isempty(f) ) % check for empty chebfun2.
        return;
    end
    op = @(x,y) f.feval(x,y).^(n.feval(x,y));
    f = chebfun2(op,f.corners);       % resample and call constructor.
end

end