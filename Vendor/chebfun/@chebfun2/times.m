function f=times(f,g)
% .*   Chebfun2 multiplication.
% 
% F.*G multiplies chebfun2 objects F and G.  Alternatively F or G could be
% a double.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) || isempty(g) 
   f = chebfun2;   % just return an empty chebfun2. 
   return; 
end


if ( isa(f,'double') )

    % If f is a scalar then its easy. 
    g.fun2.U = g.fun2.U./f;
    g.fun2.scl = f*g.fun2.scl; %update scaling. 
    g.scl=f*g.scl;
    f=g;

elseif ( isa(g,'double') )

    % If g is a scalar then its easy. 
    f.fun2.U = f.fun2.U./g;
    f.fun2.scl = g*f.fun2.scl; %update scaling.
    f.scl=g*f.scl;

elseif ( isa(f,'chebfun2') && isa(g,'chebfun2') ) 

    % If g and f are chebfun2s check they have the same domain.
    if(~all(f.corners == g.corners))
        error('Chebfun2:times:domain','Domains of chebfun2 objects do not match.');
    end

    % In general, we have to resample.
    f.fun2 = (f.fun2).*(g.fun2);

elseif isa(f,'chebfun2') && isa(g,'chebfun2v')
%% chebfun2 * chebfun2v

    % This functionality may be taken out of a release.  
    g.xcheb = f.*g.xcheb; 
    g.ycheb = f.*g.ycheb;
    if ~isempty(g.zcheb)
        g.zcheb = f.*g.zcheb;
    end
    f = g;
else

    % We had a chebfun2.*unknown, so complain. 
    error('Chebfun2:times','Can only do chebfun2 times scalar or chebfun2.');
end
end