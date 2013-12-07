function g = restrict(f,s)
% RESTRICT restrict a chebfun2 to a smaller rectangle.
%
% G = RESTRICT(F,S) returns G defined on S such that G evaluates
% to F on S. S can be an array of four doubles specifying the corners of
% the rectangle, i.e. S = [a b c d] for the domain [a b]x[c d] or a chebfun.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~isa(f,'chebfun2')
    error('CHEBFUN2:RESTRICT:inputs','Can only restrict chebfun2 objects.');
end
if ( all(isa(s,'double')) )
    if ( length(s) == 4 )
       % s is a domain, return a chebfun2 on domain S.
        if s(1)<=s(2) && s(3)<=s(4)
            % check that [s(1) s(2) s(3) s(4)] is a subset of the domain of
            % f. 
            rect = f.corners; 
            if ( s(1) < rect(1) || s(2) > rect(2) ||...
                                         s(3) <rect(3) || s(4) > rect(4) )
               error('CHEBFUN2:RESTRICT','Restriction domain is outside the chebfun2''s domain'); 
            end
            
            % return chebfun2 on domain S.
            if ( s(1) == s(2) )
                if ( s(3) == s(4) )
                    % return point evaluation.
                    g = feval(f,s(1),s(3));
                else
                    % return chebfun along the line x = s(1)
                    g = chebfun( @( t ) feval(f,s(1),t), [s(3) s(4)] );
                end
            elseif ( s(3) == s(4) )
                % return chebfun along the line x = s(3)
                g = chebfun( @( t ) feval(f,t,s(3)), [s(1) s(2)] );
            else
                % We have a non-trivial domain. Resample for now, though
                % this can be done be restricting each chebfun contained
                % within f. We resample because we want the rank to be
                % reduced appropriately. 
                g = chebfun2(@(x,y) feval(f,x,y),s); 
            end
        else
            % Empty domain.
            error('CHEBFUN2:RESTRICT:inputs','Cannot form chebfun2 on empty domain.');
        end
    else
        % unrecognised domain.
        error('CHEBFUN2:RESTRICT:inputs','Domain should be specified by its corners.');
    end
elseif ( isa(s,'chebfun') )
        g = chebfun ( @( t ) feval(f,real(s(t)),imag(s(t))), s.ends);
else
    error('CHEBFUN2:RESTRICT:inputs','Can only restrict to rectangles or along complex-valued chebfuns.');
end

end