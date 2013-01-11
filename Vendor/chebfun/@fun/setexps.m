function f = setexps(f,newexps)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

oldexps = f.exps;
ends = f.map.par(1:2);

% infinite intervals
infends = isinf(ends);
if any(infends)
    s = f.map.par(3);
    if all(infends),  rescl = (.5./(5*s));
    else              rescl = (.5./(15*s)); end
%     rescl = rescl^sum(oldexps-newexps);
else
    rescl = (2/diff(ends))^sum(oldexps-newexps);
end

f = rescl*f;
f.exps = newexps;
