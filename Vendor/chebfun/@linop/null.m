function [Vfun S] = null(A,varargin)
%NULL   Null space.
% Z = NULL(A) is a chebfun quasimatrix orthonormal basis for the null space
% of the linop A. That is, A*Z has negligible elements, size(Z,2) is the
% nullity of A, and Z'*Z = I. A may contain linear boundary conditions, but
% they will be treated as homogeneous.
%
% Example 1:
%  d = domain(0,pi);
%  A = diff(d);
%  V = null(A);
%  norm(A*V)
%
% Example 2:
%  d = domain(-1,1);
%  x = chebfun('x',d);
%  L = 0.2*diff(d,3) - diag(sin(3*x))*diff(d);
%  L.rbc = 1;
%  V = null(L)
%
% For systems of equations, NULL(S) returns a cell array of quasimatrices, 
% where the kth element in the cell, Z{k}, corresponds to the kth variable.
%
% See also linop/svds, linop/eigs, null.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin > 1
    error('CHEBFUN:linop:null:r',...
        '"rational" null space basis is not yet supported.');
end

% Grab the default settings.
maxdegree = cheboppref('maxdegree');
settings = chebopdefaults;
settings.minsamples = 33;
tol = 100*settings.eps;

% Grab some info from A
dom = domain(A);  breaks = dom.endsandbreaks;
syssize = A.blocksize(2);  % Number of variables in system

% Initialise
V = [];         % Initialise V so that the nested function overwrites it.
nullity = [];   % Also initialise nullity.
S = [];

% Call the constructor
ignored = chebfun( @(x,N,bks) value(x,N,bks), {breaks}, settings);

if nullity == 0 || size(V,2) == 0
    Vfun = chebfun;
    if syssize > 1, Vfun = repmat({Vfun},1,syssize); end
    return
end

% Clean and format the output (stored in V)
Vfun = cell(1,syssize);
for l = 1:syssize, Vfun{l} = chebfun; end % initialise
V = mat2cell(V(:),repmat(Nout,1,syssize*size(V,2)),1);
settings.maxdegree = maxdegree;  settings.maxlength = maxdegree;
for k = 1:nullity % Loop over each eigenvector
    for l = 1:syssize % Loop through the equations in the system
        tmp = chebfun; 
        % Build a chebfun from the piecewise parts on each interval
        for j = 1:numel(breaks)-1
            funj = fun( V{1}, breaks(j:j+1), settings);
            tmp = [tmp ; set(chebfun,'funs',funj,'ends',breaks(j:j+1),...
                'imps',[funj.vals(1) funj.vals(end)],'trans',0)];
            V(1) = [];
        end
        Vfun{l}(:,k) = simplify(tmp,tol);
    end
end
if syssize == 1
    Vfun = Vfun{1};         % Return a quasimatrix in this case
    Vfun = qr(Vfun);        % Orthogonalise
    Vfun = simplify(Vfun);  % Simplify
else 
    [Q R] = qr(vertcat(Vfun{:}));       % Orthogonalise
    for l = 1:syssize
        Vfun{l} = Vfun{l}/R;            % Orthogonalise and return a cell array
        Vfun{l} = simplify(Vfun{l});    % Simplify
    end
end

 function v = value(y,N,bks)
    % y is a cell array with the points for each function.
    % N is the number of points on each subinterval.
    % bks contains the ends of the subintervals.
    N = N{:};   bks = bks{:};         % We allow only the same discretization
    csN = [0 cumsum(N)]; sN = sum(N); %  size and breaks for each system.
    maxdo = max(A.difforder(:));      % Maximum derivative order of the system.

    % Error checking
    if sum(N) > maxdegree+1
      error('LINOP:mldivide:NoConverge',...
          ['Failed to converge with ',int2str(maxdegree+1),' points.'])
    elseif any(N==1)
      error('LINOP:mldivide:OnePoint',...
        'Solution requested at a lone point. Check for a bug in the linop definition.')
    elseif any(N < maxdo+1)
      % Too few points: force refinement.
      jj = find(N < maxdo+1);
      v = y;
      for kk = 1:length(jj)
          e = ones(N(jj(kk)),1); e(2:2:end) = -1;
          v{csN(jj(kk))+(1:N(jj(kk)))} = e; 
      end
      return
    end 
        
    % Get collocation matrix.
    [ignored,B,ignored,ignored,ignored,Amat] = feval(A,N,'bc',[],bks);
        
    if diff(size(Amat)),
        error('chebfun:linop:null', ...
            'Nonsquare collocation currently not supported.')
    end

    % Compute the discrete SVD
    [U,S,v] = svd(Amat);                    % Built-in SVD
    S = diag(S);
    nullity = length(find(S/S(1) < tol));   % Numerical nullity
    
    % Extract null vectors
    if nullity~=0
        v = v(:,end+1-nullity:end);         % Numerical null vectors
        % Enforce additional boundary conditions and store for output
        V = v*null(B*v);                    % Store output in V
    else
        v = v(:,end); % Check for convergence in smallest singular value
        V = [];       % No output to store as no null vectors found
    end
        
    % Reshape v to have one variable per column
    v = sum(reshape(v,[sN,max(nullity,1),syssize]),3);   
    % Need to return a single function to test happiness. If you just sum
    % functions, you get weird results if v(:,1)=-v(:,2), as can happen in
    % very basic problems. We just use an arbitrary linear combination (but
    % the same one each time!). 
    coef = [1, 2 + sin(1:nullity-1)]; % Form linear combination of variables
    v = v*coef.';
    % Filter
    for jj = 1:numel(N)
        ii = csN(jj) + (1:N(jj));
        v(ii) = filter(v(ii),1e-8);
    end
    v = {v};                  % Output as cell array for systems constructor
    Nout = N;
    nullity = size(V,2);

    end
end
