function A = setbc(A,bc)
% Set one or more of the boundary conditions. 
%
% Two options for bc: struct or mnemonic.
%
% bc struct has fields .left and .right. Each of these is a struct array
% with fields .op and .val; these define the operator on the solution and
% the value of the result at the appropriate boundary. Optional string
% values for .op are 'dirichlet' (maps to I) and 'neumann' (maps to D).
%
% bc mnemonic is a string or cell array {string,val}. If val is not given,
% it defaults to zero. If the string is 'dirichlet' or 'neumann', then the
% condition is applied at the left (1st order operator) or both sides (2nd
% order). If the string is 'periodic', you get m nonseparated conditions for
% difforder=m. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

I = eye(A.domain);
D = diff(A.domain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, turn a mnemonic call into a bc struct.
if ~isstruct(bc)
  % Apply a mnemonic rule to both ends to create the bc structure.
  % Input is 'type' or {'type',val}.
  if ischar(bc)
    type = bc;  val = 0;
  elseif iscell(bc) && length(bc)==2
    type = bc{1};  val = bc{2};
  else
    error('LINOP:setbc:invalidtype','Unrecognized boundary condition mnemonic.')
  end
  bc = struct('left',struct([]),'right',struct([]),'other',struct([]));
  switch(lower(type))
    case 'dirichlet'
      if A.difforder > 0
        bc.left = struct('op',I,'val',val(1));
        if A.difforder > 1
          bc.right = struct('op',I,'val',val(end));
          if A.difforder > 2
            warning('LINOP:setbc:order',...
              'Dirichlet may not be appropriate for differential order greater than 2.')
          end
        end
      end
    case 'neumann'
      if A.difforder > 0
        bc.left = struct('op',D,'val',val(1));
        if A.difforder > 1
          bc.right = struct('op',D,'val',val(end));
          if A.difforder > 2
            warning('LINOP:setbc:order',...
              'Neumann may not be appropriate for differential order greater than 2.')
          end
        end
      end
    case 'periodic'
      m = max(A.blocksize);
      if m == 1 % Single system case
          B = I.varmat;
          for k = 1:A.difforder
            if rem(k,2)==1
              bc.left(end+1).op = B(1,:) - B(end,:);
              bc.left(end).val = 0;
            else
              bc.right(end+1).op = B(1,:) - B(end,:);
              bc.right(end).val = 0;
            end
            B = D.varmat*B;
          end
      else      % Systems case
          order = max(A.difforder,[],1);
           Z = zeros(A.domain); Z = Z.varmat;
          for j = 1:numel(order)
              B = I.varmat;
              Zl = repmat(Z,1,j-1);
              if j > 1, Zl = Zl(1,:); end
              Zr = repmat(Z,1,m-j);
              if j < m, Zr = Zr(1,:); end
              for k = 1:order(j)
                if rem(k,2)==1
                  bc.left(end+1).op = [Zl B(1,:)-B(end,:) Zr];
                  bc.left(end).val = 0;
                else
                  bc.right(end+1).op = [Zl B(1,:)-B(end,:) Zr];
                  bc.right(end).val = 0;
                end
                B = D.varmat*B;
              end
          end
      end
    otherwise
      error('LINOP:setbc:invalidtype','Unrecognized boundary condition mnemonic.')
  end
end

if ~isfield(bc,'other'), bc.other = struct([]); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now, assign the BC structure, mapping dirichlet and neumann
% strings into operators.
A.lbc = bc.left;  A.rbc = bc.right; 
A.bc = bc.other;
for k = length(A.lbc):-1:1  % backwards to allow deletions
  if isempty(A.lbc(k).op)
    A.lbc(k) = [];
  elseif isequal(A.lbc(k).op,'dirichlet')
    A.lbc(k).op = I;
  elseif isequal(A.lbc(k).op,'neumann')
    A.lbc(k).op = D;  
  end
end
for k = length(A.rbc):-1:1
  if isempty(A.rbc(k).op)
    A.rbc(k) = [];
  elseif isequal(A.rbc(k).op,'dirichlet')
    A.rbc(k).op = I;
  elseif isequal(A.rbc(k).op,'neumann')
    A.rbc(k).op = D;
  end
end

A.numbc = length(A.lbc) + length(A.rbc) + length(A.bc);
A.ID = newIDnum;
  
end
