function [g, hpy, scl] = getfun(op, interval, pref, scl)
%GETFUN controls the constructin of funs
% [G, HPY, SCL] = GETFUN(OP, INTERVAL, PREF, SCL)
%   GETFUN returns a fun G for OP. INTERVAL is the doamin. PREF the
%   preference structure and SCL the scale structure -- horizonta and #
%    vertical scales in SCL (SCL.H and SCL.V).
%
%   The structure SCL gets uptdate within this function and is returned as
%   an output.
%
%   HPY is true if the coefficients

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Initial setup
htol = 1e-14*scl.h;

% If the interval is very small skip adaptation and return a constant
% (This should never be happen, though!)
if diff(interval) < 2*htol
    g = fun(op(mean(interval)),interval);
    scl.v = max(scl.v,g.scl.v);
    g = set(g,'scl.v',scl.v);
    hpy = true;
    %warning('CHEBFUN:getfun:SmallInterval','Small interval, fun might be unhappy')
    return
end

g = fun(@(x) op(x), interval, pref, scl);

% Check happiness.
if pref.splitting
    hpy = (g.n < pref.splitdegree+1);
else
    hpy = (g.n < pref.maxdegree+1);
end

scl.v = g.scl.v;              % Update the vertical scale.

end