function s = char(A)
% CHAR  Convert chebop to pretty-printed string.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(A)
    s = '   (empty chebop)';
else
    % Check whether the chebop is linear in order to be able to display
    % linearity information. If we get an error, that's a indicator that
    % the operator is nonlinear, as it means that it can't operate on any
    % initial guess (i.e. it could be @(u) diff(u,2) + 1./u)
    try
        L = linop(A);
        islA = 1;
    catch ME
        islA = 0;
    end
    if islA
        s ='   Linear operator operating on chebfuns defined on:';
    else
        s ='   Nonlinear operator operating on chebfuns defined on:';
    end
    s = char(s,['  ' char(A.domain)]);
    if ~isempty(A.op) && ~isempty(A.opshow) && size(A.opshow{1},1) == 1%&& ~isa(A.op,'linop')
      s = char(s, '   representing the operator:');
      for j = 1:length(A.opshow)
          s = char(s,['     ',A.opshow{j}]);
      end
    end
    
    if ~isempty(A.lbc) && ~isempty(A.lbcshow)
      s = char(s,' ');
      t = bc2char(A.lbcshow);
      if iscell(A.lbcshow) && length(A.lbcshow) > 1
        s = char(s, '   left boundary conditions:');
      else
         s = char(s, '   left boundary condition:');
      end      
      s = char(s,t{:});
    end
    
    if ~isempty(A.rbc) && ~isempty(A.rbcshow)
      s = char(s,' ');
      if iscell(A.rbcshow) && length(A.rbcshow) > 1
        s = char(s, '   right boundary conditions:');
      else
         s = char(s, '   right boundary condition:');
      end
      t = bc2char(A.rbcshow);
      s = char(s,t{:});
    end
    
    if ~isempty(A.bc) && ~isempty(A.bcshow)
      s = char(s,' ');
      t = bc2char(A.bcshow);
      if iscell(A.lbcshow) && length(A.lbcshow) > 1
        s = char(s, '   other boundary conditions:');
      elseif strcmp(strtrim(t),'periodic')
         s = char(s, '   with periodic boundary conditions.') ;
         return
      else
         s = char(s, '   other constraints:');
      end
      s = char(s,t{:});
    end
    
    if islA
      s = char(s,mat2char(L),' ');
    end
    
end

end  % main function


function s = bc2char(b)

if ~iscell(b), b = {b}; end

s = repmat({'     '},1,length(b));
for k = 1:length(b)
  if isnumeric(b{k})  % number
    s{k} = [s{k}, num2str(b{k})];
  elseif ischar(b{k})  % string
    s{k} = [s{k}, b{k}];
  else  % function
    s{k} = [s{k},char(b{k}),' = 0'];
  end
end

end

function s = mat2char(V)
% MAT2CHAR  Convert the varmat to pretty-print string (incl. BCs)

print_bc = true; % Print BCs or not
defreal = 6;  % Size of matrix to display
dom = get(V,'domain');
numints = numel(dom.endsandbreaks);
if numints == 1 && isempty(V,'bcs')
    print_bc = false;
end
defreal = max(2,ceil(defreal/(numints-1)));
s1 = ['   with n = ',int2str(defreal),' realization:'];
% Evaluate the linop
if print_bc && ~isempty(V,'bcs')
    Vmat = feval(V,defreal,'bc',dom);
else
    Vmat = feval(V,defreal,'nobc',dom);
end
% Some pretty scaling for large/small numbers
M = max(max(abs(Vmat)));
if (M > 1e2 || M < 1) && M ~= 0
  M = 10^round(log10(M)-1);
  Vmat = Vmat/M;
  s1 = [s1 sprintf('\n    %2.1e * ',M)];
end
if isreal(Vmat)
    s2 = num2str(Vmat,'  %8.4f');
    for k = 1:size(s2,1)
        s2(k,:) = strrep(s2(k,:),' 0.0000','      0');
        if numel(s2(k,:)) > 5,
            s2(k,1:6) = strrep(s2(k,1:6),'0.0000','     0'); 
        end
        s2(k,:) = strrep(s2(k,:),'-0.0000','      0');
    end
else
    s2 = num2str(Vmat,'%8.2f');
    for k = 1:size(s2,1)
        s2(k,:) = strrep(s2(k,:),'0.00 ','   0 ');
    end
end
% Pad with appropriate spaces
s2 = [ repmat(' ',size(s2,1),5) s2 ];
s = char(s1,'',s2);
end
