function [M,B,c,rowreplace,P,Mmat] = feval(A,n,usebc,map,breaks)
%FEVAL  Apply or realize a linop.
% FEVAL(A,U) for chebfun U applies A to U; i.e., it returns A*U.
%
% M = FEVAL(A,N) for integer N returns the matrix associated with A at size
% N.
%
% [M,B,C,RR] = FEVAL(A,N,'bc') modifies the matrix according to any
% boundary conditions that have been set for A. In particular, M(RR,:)=B,
% and C is a vector of boundary values corresponding to the rows in RR.
%
% FEVAL(A,Inf) returns the functional form of A if it is available.
%
% See also linop/subsref.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% For future performance, store realizations.
persistent storage
if isempty(storage), storage = struct([]); end
use_store = cheboppref('storage');

if isa(n,'chebfun')  % Apply to chebfun
  M = A*n;
  return
end

default_usebc = 1;

% Parse the inputs.
if nargin < 5, breaks = []; end
if nargin < 4, map = []; end
if nargin > 2 % Determine input sequence
    if isstruct(usebc) || isa(usebc,'function_handle') || isempty(usebc)    
        if ~isstruct(map)
            if nargin == 4, breaks = map; end % A,n,map,breaks
            if nargin < 5,  map = usebc;  end % A,n,map
        end
        if isempty(A.bc) && isempty(A.lbc) && isempty(A.rbc)
            usebc = 0;
        else
            usebc = default_usebc;
        end
    elseif nargin == 3 && ((isnumeric(usebc) && numel(usebc) > 1) || isa(usebc,'domain'))
        % A,n,breaks
        breaks = usebc; map = []; usebc = 0;
    else
        % A,n,usebc,*
        usebc = .5*strcmpi(usebc,'rect') + 1.0*strcmpi(usebc,'bc') + ...
            1.5*any(strcmpi(usebc,{'oldschool','rowrep'}));
    end
else % A,n
    if isempty(A.bc) && isempty(A.lbc) && isempty(A.rbc)
        usebc = 0;
    else
        usebc = default_usebc;
    end
end
if nargin < 5 && ~isempty(map) && (isnumeric(map) || isa(map,'domain'))
    breaks = map; map = []; % A,n,usebc,breaks
end

% usebc = 0 ('nobc') --> No boundary conditions
% usebc = 0.5 ('rect') --> Compute the projection, but don't add BCs
% usebc = 1 ('bc') --> Compute projections and apply boundary conditions
% usebc = 1.5 ('rowrep') --> Use row replacement rather than rectangular matrices

% Initialise output variables
M = []; B = []; c = []; rowreplace = []; P = [];

% Sort out the breaks
if isa(breaks,'domain'), breaks = breaks.endsandbreaks; end
breaks = sort(breaks);
if ~isempty(breaks) && (breaks(1) < A.domain(1) || breaks(end) > A.domain(end))
    error('CHEBFUN:linop:breaksdomain','Breaks must be within domain of linop');
end
if ( isempty(breaks) )
    breaks = A.domain.endsandbreaks;
else
    breaks = union(breaks,A.domain.endsandbreaks);
end

% We set trivial maps and breaks to empty
if numel(breaks) == 2 && ~any(isempty(breaks)), breaks = []; end
if isstruct(map) && strcmp(map(1).name,'linear'), map = []; end

% Repeat N if the user has been lazy
if numel(n) == 1 && ~isempty(breaks)
  n = repmat(n,1,numel(breaks)-1);
end

% Force maps for unbounded domains
if isempty(map) && (any(isinf(breaks)) || any(isinf(A.domain([1 end]))))
    domA = A.domain([1 end]);
    mapdomain = domain(union(breaks,domA.endsandbreaks));
    map = maps(mapdomain);
end
  
% %%%%%%%%%% function (i,e., infinite dimensional operator) %%%%%%
if any(isinf(n))  
  if ~isempty(A.oparray)
    M = A.oparray;
    if A.numbc && usebc > 0
      warning('LINOP:feval:funbc',...
        'Boundary conditions are not imposed in the functional form.')
    end
  else
    error('LINOP:feval:nofun',...
      'This operator does not have a functional form defined.')
  end

else
% %%%%%%%%%%%%%%%%%%%% matrix representation %%%%%%%%%%%%%%%%%%%%%
  
  % We don't use storage if there's a nontrivial map 
  if ~isempty(map), use_store = 0; end
  % Nor if numel(n) > 1
  if numel(n) > 1, use_store = 0; end
  % Or if we have a non-trivial domain
  if ~isempty(breaks), use_store = 0; end
  
    % Is the matrix already exists in storage?
  if use_store && n > 4 && length(storage)>=A.ID ...
      && length(storage(A.ID).mat)>=n && ~isempty(storage(A.ID).mat{n})
    M = storage(A.ID).mat{n};
  else % If not,m then make it.
%     try
        M = feval(A.varmat,{n,map,breaks});
%     catch
%         if ~isempty(map) || ~isempty(breaks)
%             error('CHEBFUN:linop:feval:cellin',...
%                 'This linop definition does not allow maps or breaks.');
%         end
%         M = feval(A.varmat,n);
%     end
    if use_store && n > 4
      % This is very crude garbage collection! 
      % If size is exceeded, wipe out everything.
      ssize = whos('storage');
      if ssize.bytes > cheboppref('maxstorage')
        storage = struct([]); 
      end
      storage(A.ID).mat{n} = M;
    end 
  end
  
  if nargout >= 6, Mmat = M; end
  
% %%%%%%%%%%%%%%%%%%%%%% Boundary conditions %%%%%%%%%%%%%%%%%%%%%%

  % No boundary conditions
  if ~usebc, return, end
  
  % Old school row replacement
  if usebc == 1.5
      if ~isempty(breaks)
          % We force rectangular matrices in this case.
          warning('CHEBFUN:linop:feval:rowrep', ...
              '''rowrep'' does not support piecewise linops.');
      else
          [B,c,rowreplace] = bdyreplace_old(A,n,map,breaks);
          M(rowreplace,:) = B;
          return
      end
  end

  % Rectangular matrices and boundary conditions
  if max(A.blocksize) == 1  % Single equation
      if isempty(breaks)     % No breakpoints
          % Project
          P = barymatp12m(n-abs(A.difforder),n,[-1 1],map);
          if isempty(P)
              M = [];
          else
              M = P*M;
          end
          % Compute boundary conditions and apply (if required)
          if usebc == 1
              [B,c] = bdyreplace(A,{n},map,{breaks});
              rowreplace = sum(n)-(size(B,1)-1:-1:0);
              M = [M ; B];
          end
      else                   % Break points
          % Project
          P = barymatp12m(n-abs(A.difforder),n,breaks,map);
          if isempty(P)
              M = [];
          else
              M = P*M;
          end
          % Compute boundary conditions and apply (if required)
          if usebc == 1
              [B c] = bdyreplace(A,{n},map,{breaks});
              [C c2] = cont_conds(A,{n},map,{breaks});
              B = [B ; C];  c = [c ; c2];
              M = [M ; B]; 
              rowreplace = sum(n)-(size(B,1)-1:-1:0);
          end
      end
  else                     % System of equations
      % Project
      MM = []; sn = sum(n);
      do = max(abs(A.difforder),[],2); % Max difforder for each equation
      sizeM = A.blocksize(1)*sn; 
      nbc = sizeM;
      P = cell(A.blocksize(1),1);
      for k = 1:A.blocksize(1)
          nk = n-do(k);
%           if any(nk<1), error('CHEBFUN:linop:feval:fevalsize', ...
%                   'feval size is not large enough for linop.difforder.');
%           end
          if nk > 0
              Pk = barymatp12m(nk,n,breaks,map);
              ii = ((k-1)*sn+1):k*sn;
              MM = [MM ; Pk*M(ii,:)];
          end
          if nargout >= 5, P{k} = Pk; end % Store P
          nbc = nbc - sum(nk);
      end

%       % Construct the full matrix version of P.
%       Pmat = zeros(sum(n)*A.blocksize(1));
%       i1 = 0; i2 = 0;
%       for j = 1:A.blocksize(1)
%           ii1 = i1+(1:size(P{j},1));
%           ii2 = i2+(1:size(P{j},2));
%           Pmat(ii1,ii2) = P{j};
%           i1 = ii1(end); i2 = ii2(end);
%       end   
      
      M = MM;
      % Compute boundary conditions and apply
      if usebc == 1
          breaks = repmat({breaks},1,A.blocksize(2));
          n = repmat({n},1,A.blocksize(2));
          [B c] = bdyreplace(A,n,map,breaks);
          [C c2] = cont_conds(A,n,map,breaks);
          B = [B ; C]; c = [c ; c2];
          M = [M ; B]; 
          rowreplace = sizeM-nbc+(1:nbc);          
      end
  end

end


