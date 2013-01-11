function u = newID(u)
% NEWID Assigns a new ID to a chebfun. 
%
% This is in particular useful for quasimatrices when we linearise, where
% we want to ensure that all columns of the quasimatrix have unique IDs.

for k = 1:numel(u)
    u(k) = set(u(k),'ID',newIDnum());
end