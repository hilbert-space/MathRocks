function [B,c,rowidx] = bdyreplace_old(A,n,map,breaks)
% Each boundary condition in A corresponds to a constraint row of the form 
% B*u=c. This function finds all rows of B and c, and also the indices of
% rows of A*u=f that should be replaced by them.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 3, map = []; end
if nargin < 4, breaks = []; end

breaks = union(breaks,A.domain.endsandbreaks);
if ~isempty(breaks) && numel(breaks) > 2
    numints = numel(breaks)-1;
    if numel(n) == 1, n = repmat(n,1,numints); end
    if numel(n) ~= numints
        error('DOMAIN:eye:numints','Vector N does not match domain D.');
    end
elseif numel(breaks) == 2;
    breaks = []; 
end

m = size(A,2);
B = zeros(A.numbc,sum(n)*m);
c = zeros(A.numbc,1);
rowidx = zeros(1,A.numbc);
if A.numbc==0, return, end

elimnext = 1:n:m*n;  % in each variable, next row to eliminate
q = 1;
for k = 1:length(A.lbc)
  op = A.lbc(k).op;
  if size(op,2)~=m && ~isa(op,'varmat')
    error('LINOP:bdyreplace:systemsize',...
      'Boundary conditions not consistent with system size.')
  end
  if isa(op,'function_handle')
      T = NaN(1,n*m);
  else
      if isa(op,'varmat')
          T = feval(op,{n,map,breaks});
      else
          T = feval(op,n,0,map,breaks);
      end
      if size(T,1)>1, T = T(1,:); end   % at left end only
  end
  B(q,:) = T;
  c(q) = A.lbc(k).val;
  if numel(breaks) < 3
      nz = any( reshape(T,n,m)~=0 );    % nontrivial variables
      j = find(full(nz),1,'first');     % eliminate from the first
      rowidx(q) = elimnext(j);
      elimnext(j) = elimnext(j)+1;
  end
  q = q+1;
end
elimnextleft = elimnext;

elimnext = n:n:n*m;  % in each variable, next row to eliminate
for k = 1:length(A.rbc)
  op = A.rbc(k).op;
  if size(op,2)~=m && ~isa(op,'varmat')
    error('LINOP:bdyreplace:systemsize',...
      'Boundary conditions not consistent with system size.')
  end
  if isa(op,'function_handle')
      T = NaN(1,n*m);
  else
      if isa(op,'varmat')
          T = feval(op,{n,map,breaks});
      else
          T = feval(op,n,0,map,breaks);
      end
      if size(T,1)>1, T = T(end,:); end   % at right end only
  end
  B(q,:) = T;
  c(q) = A.rbc(k).val;
  if numel(breaks) < 3
      nz = any( reshape(T,n,m)~=0 );      % nontrivial variables 
      j = find(full(nz),1,'last');        % eliminate from the last
      rowidx(q) = elimnext(j);
      elimnext(j) = elimnext(j)-1;
  end
  q = q+1;
end
elimnextright = elimnext;

% Deal with the rmailing bcs. Alternate from left to right.
leftright = length(elimnextleft)<=length(elimnextright);
for k = 1:length(A.bc)
  op = A.bc(k).op;
  if size(op,2)~=m && ~isa(op,'varmat')
    error('LINOP:bdyreplace:systemsize',...
      'Boundary conditions not consistent with system size.')
  end
  if isa(op,'function_handle')
      T = NaN(1,n*m);
  else
      if isa(op,'varmat')
          T = feval(op,{n,map,breaks});
      else
          T = feval(op,n,0,map,breaks);
      end
      if size(T,1)>1, T = T(end,:); end    % at right end only
  end
  B(q,:) = T;
  c(q) = A.bc(k).val;
  if numel(breaks) < 3
      nz = any( reshape(T,n,m)~=0 );       % nontrivial variables 
      if leftright
          j = find(full(nz),1,'first');    % eliminate from the first
          rowidx(q) = elimnextleft(j);
          elimnextleft(j) = elimnextleft(j)+1;
          leftright = false;
      else
          j = find(full(nz),1,'last');     % eliminate from the last
          rowidx(q) = elimnextright(j);
          elimnextright(j) = elimnextright(j)-1;
          leftright = true;
      end
  end
  q = q+1;
end

end
