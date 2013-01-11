function fout = eq(F1,F2)
% EQ Pointwise equality test for two chebfuns.
%
% FOUT=EQ(F1,F2) returns a chebfun FOUT which is zero everywhere except at 
% the intersection points of F1 and F2, where it evaluates to one.
% 
% This function is called automatically with ==.
% 
% Example:
%   x = chebfun(@(x) x);
%   plot(sign(x) == 1)
%
% See also chebfun/find, chebfun/ne, chebfun/not.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Make sure F1 is a chebfun
if ~isa(F1,'chebfun')
    Ftemp = F1;
    F1 = F2;
    F2 = Ftemp;
end

if isa(F2,'double')
    % if F2 is a scalar repeat to match number of columns in F1
    F2 = repmat(F2,1,numel(F1));
elseif size(F1) ~= size(F2) 
    % two quasimatrices must have the same size
    error('CHEBFUN:eq:wrongsize','Quasimatrix dimensions must agree')
end

fout = chebfun;
for k = 1:min(size(F1)) % Do it for each column of F1.
      fout = [fout  eqcol(F1(k), F2(k))];
end

function fout = eqcol(f1,f2)
% Eq for two single chebfuns or one chebfun and one scalar
% Note: f1 must be a chebfun, f2 may be a scalar

fout = sign(f1-f2);
for k = 1:fout.nfuns
    if all(fout.funs(k).vals) == 0
        fout.funs(k) = fun(1,fout.ends(k:k+1));
    else 
        fout.funs(k) = fun(0,fout.ends(k:k+1));
    end
end

fout.imps = fout.imps + 1;
if fout.imps(1) ~= 1
    fout.imps(1) = 0;
end
if fout.imps(end) ~= 1
    fout.imps(end) = 0;
end