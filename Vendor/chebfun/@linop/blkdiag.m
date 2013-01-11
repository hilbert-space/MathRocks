function B = blkdiag(varargin)
% BLKDIAG Block linop.
% B = BLKDIAG(A1,A2,...,Am), where each Aj is a linop on a common domain,
% produces
%
%           [ A1  0 ... 0  ]
%     B =   [  0 A2 ... 0  ]
%           [       ...    ]
%           [  0  0 ... Am ]
%
% B = BLKDIAG(A,M) produces a block diagonal linop with M copies of A on
% the diagonal.
%
% See also blkdiag.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% If given (A,m) as arguments, replace with {A,A,...,A}.
if nargin==2 && isnumeric(varargin{2})
  varargin = repmat(varargin(1),[1,varargin{2}]);
end

m = length(varargin);
if m == 1, B = varargin{1}; return, end      % nothing to do here

dom = domaincheck(varargin{:});
Z = zeros(dom);  
B = linop([],[],dom,0);

% Get the sizes of each block
for i = 1:m  
  s(i,:) = size(varargin{i});
end
S = sum(s);

% Build B one row at a time.
for i = 1:m  
  Zl = repmat(Z,s(i,1),sum(s(1:i-1,2)));     % left zeros
  Zr = repmat(Z,s(i,1),S(2)-sum(s(1:i,2)));  % right zeros
  row = [ Zl varargin{i} Zr];                % build the row
  B = [B; row];                              % insert the row
end

end
