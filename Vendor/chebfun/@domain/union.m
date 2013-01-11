function d = union(d1,d2)
%UNION  union of two domains
% UNION(D1,D2) returns, if D1 == D2, and domain D such that D == D1 and D
% contains the union of the breakpoints of D1 and D2.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(d1,'domain') d1 = d1.ends; end
if isa(d2,'domain') d2 = d2.ends; end

if ~isempty(d1) && ~isempty(d2) && ~all(d1([1 end])==d2([1 end]))
    error('CHEBFUN:domain:union:iisequal','Inconsistent domains.');
end

d = domain(union(d1,d2));