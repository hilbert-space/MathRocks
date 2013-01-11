function gout = mtimes(g1,g2)
% *	Scalar multiplication
% k*G or G*k multiplies a fun G by a scalar k.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (isempty(g1) || isempty(g2)), gout = fun; return, end
if (isa(g1,'double'))
    gout = g2;
    if numel(gout) > 1
        for k = 1:numel(gout)
            gout(k) = mtimes(g1,gout(k));
        end
        return
    end
    gout.vals  = g1*gout.vals;
    gout.coeffs  = g1*gout.coeffs;
    gout.scl.v = abs(g1)*gout.scl.v;
elseif (isa(g2,'double'))
    gout = g1;
    if numel(gout) > 1
        for k = 1:numel(gout)
            gout(k) = mtimes(gout(k),g2);
        end
        return
    end
    gout.vals  = g2*gout.vals;
    gout.coeffs  = g2*gout.coeffs;
    gout.scl.v = abs(g2)*gout.scl.v;
elseif(isa(g1,'fun') && isa(g2,'fun'))
    error('FUN:mtimes:funfun','Use .* to multiply funs.');
end
if gout.scl.v == 0;
    gout.vals = 0;
    gout.coeffs = 0;
    gout.n = 1;
    gout.exps = [0 0];
end