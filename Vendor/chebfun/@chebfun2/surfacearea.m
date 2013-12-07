function I = surfacearea(f , varargin )
%SURFACEAREA of a chebfun2.
%
% SURFACEAREA(F) computes the surface area of the chebfun2 in the domain
% of F.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( nargin > 1 )
    if ( isa(varargin{1},'double') )
        if ( length(varargin{1}) == 4 )
            % restricted surface area over rectangular region. 
            rect = varargin{1}; 
            f = restrict(f,rect);
        else
            error('CHEBFUN2:SURFACEAREA:domain','Bad domain.');
        end
    elseif ( isa(varargin{1},'chebfun') )
        f = restrict(f,varargin{1});
        % surface area is now just the arc length. 
        I = sum(sqrt( 1 + diff(f).^2) ); 
        return
    else
        error('CHEBFUN2:SURFACEAREA:domain','Bad restricting domain.');
    end
end

dfdx = diff(f,1,2); dfdy = diff(f,1,1); % first order derivatives.

dfdx2 = dfdx.^2; dfdy2 = dfdy.^2;       % second order derivatives.

G = dfdx2 + dfdy2 + 1;                  % integrand.
S = sqrt(G);

I = integral2(S);                       % Surface area.

end