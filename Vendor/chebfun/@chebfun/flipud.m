function F = flipud(F)
% FLIPUD  Flip/reverse a chebfun or quasimatrix.
% 
% G = FLIPUD(F) returns a column chebfun G, if F is a column chebfun, with
% the same domain as F but reversed; that is, G(x)=F(a+b-x), where the
% domain is [a,b]. 
% 
% If F is a column quasimatrix, FLIPUD(F) applies the above operation is to
% each column of F.
%
% If F is a row chebfun, FLIPUD(F) has no effect. If F is a row
% quasimatrix, FLIPUD(F) reverses the order of the rows. 
%
% See also chebfun/fliplr.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Deal with quasi-matrices
if F(1).trans
    F = F(end:-1:1);
else
    for k = 1:numel(F)
        F(k) = flipudcol(F(k));
    end
end

% -------------------------
function f = flipudcol(f)

if ~f.trans
    % Reverse and translate the breakpoints.
    f.ends = -fliplr(f.ends) + sum(f.ends([1 end]));
    f.imps = fliplr(f.imps);
    % Reverse the order of funs, 
    f.funs = f.funs(end:-1:1);
    % and the funs themselves.
%     dfun = fun; % dummy fun
    for k = 1:f.nfuns, 
        f.funs(k) = flipud(f.funs(k),f.ends(k:k+1)); 
%         pars = f.funs(k).map.par; pars(1:2) = [];
%         f.funs(k).map = maps(dfun,f.funs(k).map.name,f.ends(k:k+1),pars);
    end
end
