function A = subsref(A,s)
% SUBSREF  Row or column reference, or matrix realization.
% V{N} produces the size-N matrix realization of varmat V.
%
% V(I,J) creates a new varmat with selected rows and columns of V. Each
% index I and J can be a ':', one or more fixed numbers, the keyword 'end',
% or a function of N.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.n.

valid = false;
switch s(1).type
  case '{}'
    t = s(1).subs;
    if length(t)==1 && isnumeric(t{1})  % return a realization (matrix)
      n = t{1};
      A = feval(A,n);
      valid = true;
    end
  case '()'
    t = s(1).subs;
    if length(t)==2                     % define a slice
      A.rowsel = parseidx(t{1});
      A.colsel = parseidx(t{2});
      valid = true;
    elseif length(t)==1                 % return realization
      A = feval(A,t{1});
      valid = true;
    end
end

if ~valid
  error('VARMAT:subsref:invalid','Invalid reference syntax.')
end

end

function sel = parseidx(idx)

if isequal(idx,':')
  sel = [];
elseif isnumeric(idx)
  sel = @select;
elseif isa(idx,'function_handle')
  sel = idx;
else
  error('VARMAT:subsref:badindex',...
    'Index must be a :, value, or function handle.')
end

  function num = select(n)
    % Use the 1i*Inf kludge to separate "forward" indices from "backward"
    % ones.
    num = zeros(size(idx));
    i = isinf(idx);
    num(~i) = idx(~i);
    if iscell(n), n = n{1}; end
    if any(i)
        num(i) = sum(n)+real(idx(i));
    end
  end

end
