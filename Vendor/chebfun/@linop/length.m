function l = length(L)
% LENGTH   Return the 'length' of a linop
%  LENGTH(L) wil return
%   0:   for an empty linop
%   1:   for an N * inf linop
%   inf: for an inf * inf linop

% l = L.length;

if isempty(L), l = 0; return, end

LL = feval(L,5,'nobc');
bsize = L.blocksize;

if size(LL,1) > bsize(1) && any(any(diff(LL)))
    l = inf;
else
    l = 1;
end