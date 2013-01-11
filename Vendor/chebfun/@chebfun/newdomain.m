function f = newdomain(g,dom)
% NEWDOMAIN   Change of domain of a chebfun.
%
% NEWDOMAIN(G,DOM) returns the chebfun G but moved to the domain DOM. 
% This is done with a linear map. DOM may be a vector of length G.ends, 
% or a two-vector (in which case all breakpoints are scaled by the same
% amount).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(dom,'domain'), dom = dom.ends; end

for k = 1:numel(g)
    % Loop over the chebfuns
    f(k) = newcol(g(k),dom);
end

function g = newcol(g,dom)

% Current breakpoints
ends = g.ends;

if numel(dom) == numel(ends)
    % All new breakpoints are given
    newdom = dom;
elseif numel(dom) == 2
    % Scale breakpoints
    c = ends(1); d = ends(end);
    a = dom(1);  b = dom(2);
    scl = (b-a) / (d-c);
    newdom = scl*(ends-c) + a;
else
    error('CHEBFUN:newdomain:numints','Insconsistent domains.');
end

for k = 1:g.nfuns
    % Update the domains of each of the funs
    g.funs(k) = newdomain(g.funs(k),newdom(k:k+1));
end
% Update the chebfun
g.ends = newdom;
