function a = any(F,dim)
% ANY    True if any element of a chebfun is a nonzero number. 
%        ANY ignores entries that are NaN (Not a Number).
%
% ANY(X,DIM), where X is a quasimatrix, works down the dimension DIM.
% If DIM is the chebfun (continuous) dimension, then ANY returns a
% logical column vector (or row) in which the Jth element is TRUE if 
% any element of the Jth column (or row) is nonzero. Otherwise, ANY
% returns a chebfun which takes the value 1 wherever any of the columns
% (or rows) of X are nonzero, and zero everywhere else.
%
% See also CHEBFUN/ALL.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information

% Get the dimension if non is passed
if isempty(F), trans = 0; else trans = get(F(1),'trans'); end
if nargin == 1                    
    dim = 1;                        % default along columns
    if min(size(F))==1 && trans
       dim = 2;                     % ...except for single row chebfun
    end 
end
         
% Deal with row chebfuns
if trans
  dim = 3-dim;
  F = F';
end
if dim == 1
    % Along the continuous dimension (standard)
    a = false(numel(F),1);
    for k = 1:numel(F)
        a(k) = anycol(F(k));
    end
else
    % Across the quasimatrix columns (or rows).
    a = anydim2(F);
    if get(F(1),'trans'), a = a'; end
end

function a = anycol(f)
% ANY along the continuous dimension
a = true;
if isempty(f)
    a = false; return
end
imps = get(f,'imps');
if any(imps(1,:)),     return, end
% if any(get(f,'exps')), return, end
if any(get(f,'vals')), return, end
a = false;

function a = anydim2(F)
% ANY across quasimatrix columns
if isempty(F), a = F; return, end % Deal with empty chebfun case
a = sum(abs(sign(F)),2);          % Sum over columns of abs(sign(F))
for k = 1:a.nfuns                 % Each fun is now a constant
    a.funs(k).vals = double(any(a.funs(k).vals));   % Convert to 0 or 1.
end
a.imps = double(logical(a.imps(1,:)));              % And the imps
% Merge
remove = zeros(a.nfuns+1,1);
for k = 1:a.nfuns-1
   if a.funs(k).vals == a.funs(k+1).vals && a.funs(k).vals == a.imps(1,k+1)
       remove(k+1) = 1;           % This interval can be removed
   end
end
ends = a.ends(~remove);
imps = a.imps;
for k = 1:numel(ends)-1
    a = define(a,domain(ends(k:k+1)),feval(a,mean(ends(k:k+1))));
end
% 08/06/2011 NicH : define(f,dom,g) takes its new imps from g, so reapply:
a.imps = imps(~remove);