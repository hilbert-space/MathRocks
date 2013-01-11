function A = subsref(A,s)
%SUBSREF  Extract information from a linop.
% A(N) returns a realization of the linop A at dimension N. If N is
% infinite, the functional form of the operator is returned as a function
% handle. If N is finite, any boundary conditions on A will be applied to
% some rows of A. (This is equivalent to the output of FEVAL(A,N,'bc').)
%
% A(I,J) returns a linop that selects certain rows or columns from the
% finite-dimensional realizations of A. A(1,:) and A(end,:) are examples of
% valid syntax. Normally this syntax is not needed at the user level, but 
% it may be useful for expressing nonseparated boundary conditions, for
% example.
%
% A.bc returns a structure describing the boundary conditions expected for 
% functions in the domain of A. The result has fields 'left' and 'right',
% each of which is itself an array of structs with fields 'op' describing
% the operator on the solution at the boundary and 'val' with the imposed
% value there.
%
% A.scale returns the global scale set for linear system solution, as
% described in the documentation for mldivide.
%
% See also linop/subsasgn, linop/feval, linop/and.
% See http://www.maths.ox.ac.uk/chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

valid = false;
switch s(1).type
  case '{}'                              
  case '()'                          
    t = s(1).subs;
    if isa(t{1},'chebfun')
      A = mtimes(A,t{1});
      valid = true;
    elseif length(t)==2 && strcmp(t{2},':')
      % Will return first row, last row, or both only.
      firstrow = t{1}==1;
      lastrow = isinf(t{1}) & real(t{1})==0;
      pts = [];
      if any(firstrow), pts = [pts; A.domain(1)]; end
      if any(lastrow), pts = [pts; A.domain(2)]; end
      if isequal(t{2},':') && ~isempty(pts)
        mat = subsref(A.varmat,s);
        op = @(u) feval(A*u,pts);
        A = linop(mat,op,A.domain );
        valid = true;
      end
    elseif isnumeric(t{1}) % return a realization (feval)
%       if length(t) > 1 && ~iscell(t{2}) && strcmpi(t{2},'bc'), t(2) = []; end
      if length(t) == 1, t{2} = []; end
      if ~ischar(t{2})
          if numel(t) == 4, t(2) = []; end
          if A.numbc > 0
              t = {t{1} 'bc' t{2:end}}; % By default we apply the bcs
%           else
%               t = {t{1} 'rect' t{2:end}}; % By default return rectmat
          end
      end
      A = feval(A,t{:});
      valid = true;
   end
  case '.'
    valid = true;
    switch(s(1).subs)
      case 'bc'
        A = getbc(A);
      case 'lbc'
        A = getbc(A);
        A = A.left;
        if length(s)>1
          A = subsref(A,s(2:end));  % respect deeper indexing
        end
      case 'rbc'
        A = getbc(A);
        A = A.right;
        if length(s)>1
          A = subsref(A,s(2:end));  % respect deeper indexing
        end
      case 'scale'
        A = A.scale;
      case 'blocksize'
        A = A.blocksize;
      case 'numbc'
        A = A.numbc;
      case 'difforder'
        A = A.difforder;
      case 'ID'
        A = A.ID;
      case 'mat'
        A = A.varmat;
      case 'iszero'
        A = A.iszero;
      case 'isdiag'
        A = A.isdiag; 
      case 'jumpinfo'
        A = A.jumpinfo; 
      case {'domain','fundomain'}
        A = A.domain;
      otherwise 
        valid = false;
    end
 end

if ~valid
  error('LINOP:subsref:invalid','Invalid reference syntax.')
end
