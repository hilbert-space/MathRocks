function A = vertcat(varargin)
% VERTCAT   Vertically concatenate linops. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Take out empties.
empty = cellfun( @isempty, varargin );
varargin(empty) = [];

% Is it now trivial?
if length(varargin)==1
  A = varargin{1};
  return
end

% Reassign numeric inputs to linops
isnum = cellfun( @isnumeric, varargin );
if any(isnum)
    d = domain(varargin{find(~isnum,1)});
    Z = zeros(d); I = eye(d);
    idx = find(isnum);
    for k = 1:numel(idx)
        vi = varargin{idx(k)};  % the scalar or matrix that has to be replaced
        if numel(vi)==1
          if vi==0, newop = Z; else newop = vi*I; end
        else
          % Linops don't support block-level indexing. Thus, we have to
          % recursively horzcat and vertcat our way up to the basic block
          % matrix here. Slow!
          newop = [];     % preserve the block shape
          for i = 1:size(vi,1)
            row = {};
            for j = 1:size(vi,2)
              if vi(i,j) == 0
                row(j) = {Z};
              else
                row(j) = {vi(i,j)*I};
              end
            end
            row = horzcat(row{:});
            newop = [newop;row];
          end
        end      
        varargin{idx(k)} = newop;
    end
end

% Check size compatibility.
bs2 = cellfun( @(A) A.blocksize(2), varargin );
if any(bs2~=bs2(1))
  error('LINOP:vertcat:badsize','Each block must have the same number of columns.')
end

% Check domain compatibility.
dom = domaincheck( varargin{:} );

% Cat the varmats.
V = cellfun( @(A) A.varmat, varargin, 'uniform',false );
V = vertcat(V{:});

% Cat the operators.
op = cellfun( @(A) A.oparray, varargin, 'uniform',false );
op = vertcat( op{:} );

% Keep track of difforders, zeros, and diags
difford = []; isz = []; isd = [];
for k = 1:numel(varargin)
    difford = [difford ; varargin{k}.difforder];
    isz = [isz ; varargin{k}.iszero];
    isd = [isd ; varargin{k}.isdiag];
end

A = linop( V, op, dom, difford );

% Update the block size.
bs1 = cellfun( @(A) A.blocksize(1), varargin );
A.blocksize = [sum(bs1) bs2(1)];

% Update iszero and isdiag.
A.iszero = isz;
A.isdiag = isd;

end
