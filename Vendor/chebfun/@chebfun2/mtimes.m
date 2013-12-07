function f = mtimes(f,g)
%*	Chebfun2 multiplication.
%
% c*F or F*c multiplies a chebfun2 F by a scalar c.
%
% See also TIMES.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) || isempty(g) )  % just return an empty chebfun2
    f = chebfun2;
    return;
end

if ( isa(f,'double') )
    %% double * chebfun2
    if numel(f) == 1
        % Times with double, and update scaling.
        g.fun2.U = (g.fun2.U)./f;
        g.fun2.scl = abs(f)*g.fun2.scl;
        g.scl=abs(f)*g.scl;
        
        f=g;
    elseif numel(f) == 2
        f = [f(1)*g;f(2)*g];
    elseif numel(f) == 3
        f = [f(1)*g;f(2)*g;f(3)*g];
    else
        error('CHEBFUN2:MTIMES:DOUBLE','Vector must be of length two or three.');
    end
elseif ( isa(g,'double') )
    %% chebfun2 * double
    if numel(g) == 1
        % Times with double, and update scaling.
        f.fun2.U = (f.fun2.U)./g;
        f.fun2.scl = abs(g)*f.fun2.scl;
        f.scl = f.scl*abs(g);
        
    elseif numel(g) == 2
        f = [g(1)*f;g(2)*f];
    elseif numel(g) == 3
        f = [g(1)*f;g(2)*f;g(3)*f];
    else
        error('CHEBFUN2:MTIMES:DOUBLE','Vector must be of length two or three.');
    end
    
elseif ( isa(f,'chebfun2') && isa(g,'chebfun2') )
    %% chebfun2 * chebfun2
    error('CHEBFUN2:mtimes:dim','mtimes does not support chebfun2 * chebfun2. Did you mean f.*g?');
    
elseif isa(f,'chebfun2') && isa(g,'chebfun')
    %% chebfun2 * chebfun
    mode = chebfun2pref('mode'); rect = f.corners;
    if ( ~mode )
        C = chebfun(f.fun2.C,rect(3:4));
        R = chebfun(f.fun2.R.',rect(1:2)).';
    else
        C = f.fun2.C; R=f.fun2.R;
    end
    f = C * (diag(1./f.fun2.U) * (R * g));
    f = simplify(f);
elseif isa(f,'chebfun2') && isa(g,'chebfun2v')
    g.xcheb = f.*g.xcheb;
    g.ycheb = f.*g.ycheb;
    if ~isempty(g.zcheb)
        g.zcheb = f.*g.zcheb;
    end
    f = g;
else
    error('CHEBFUN2:MTIMES','mtimes does not support this.');
end

end