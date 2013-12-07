function varargout = eigs(A,varargin)
% EIGS  Find selected eigenvalues and eigenfunctions of a linop.
% D = EIGS(A) returns a vector of 6 eigenvalues of the linop A. EIGS will
% attempt to return the eigenvalues corresponding to the least oscillatory
% eigenfunctions. (This is unlike the built-in EIGS, which returns the
% largest eigenvalues by default.)
%
% [V,D] = EIGS(A) returns a diagonal 6x6 matrix D of A's least oscillatory
% eigenvalues, and the corresponding eigenfunctions in V. If A operates on
% a single variable, then V is a quasimatrix of size Inf-by-6. If A
% operates on m (m>1) variables, then V is a 1-by-m cell array of
% quasimatrices. You can also use [V1,V2,...,Vm,D] = EIGS(A) to get
% a separate quasimatrix for each variable.
%
% EIGS(A,B) solves the generalized eigenproblem A*V = B*V*D, where B
% is another linop.
%
% EIGS(A,K) and EIGS(A,B,K) find the K smoothest eigenvalues.
%
% EIGS(A,K,SIGMA) and EIGS(A,B,K,SIGMA) find K eigenvalues. If SIGMA is a
% scalar, the eigenvalues found are the ones closest to SIGMA. Other
% selection possibilities for SIGMA are:
%    'LM' (or Inf) and 'SM' for largest and smallest magnitude
%    'LR' and 'SR' for largest and smallest real part
%    'LI' and 'SI' for largest and smallest imaginary part
% SIGMA must be chosen appropriately for the given operator. For
% example, 'LM' for an unbounded operator will fail to converge.
%
% Despite the syntax, this version of EIGS does not use iterative methods
% as in the built-in EIGS for sparse matrices. Instead, it uses the
% built-in EIG on dense matrices of increasing size, stopping when the
% targeted eigenfunctions appear to have converged, as determined by the
% chebfun constructor.
%
% EXAMPLE: Simple harmonic oscillator
%
%   d = domain(0,pi);
%   A = diff(d,2) & 'dirichlet';
%   [V,D] = eigs(A,10);
%   format long, sqrt(-diag(D))  % integers, to 14 digits
%
% See also EIGS, EIG.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Parsing inputs.
B = [];  k = 6;  sigma = []; map = [];
gotk = false;
j = 1;
while (nargin > j)
    if isa(varargin{j},'linop')
        B = varargin{j};
    elseif isstruct(varargin{j}) && isfield(varargin{j},'name')
        if ~strcmp(varargin{j}.name,'linear')
            map = varargin{j};
        end
    else
        % k must be given before sigma.
        if ~gotk
            k = varargin{j};
            gotk = true;
        else
            sigma = varargin{j};
        end
    end
    j = j+1;
end

% This shouldn't happen, but we might as well deal with it.
if ischar(k), sigma = k; k = []; end
if isnan(k) || isempty(k), k = 6; end

maxdegree = cheboppref('maxdegree');
m = A.blocksize(2);
if m ~= A.blocksize(1)
    error('LINOP:eigs:notsquare','Block size must be square.')
end

domA = A.domain;
if ~isempty(B)
    domB = B.domain;
    dom = union(domA,domB);
    A.domain = dom;
    B.domain = dom;
else
    dom = domA;
end
breaks = dom.endsandbreaks;
numints = numel(breaks)-1;

if isempty(sigma)
    % Try to determine where the 'most interesting' eigenvalue is.
    [V1,D1] = bc_eig(A,B,33,33,0,map,breaks);
    [V2,D2] = bc_eig(A,B,65,65,0,map,breaks);
    lam1 = diag(D1);  lam2 = diag(D2);
    dif = repmat(lam1.',length(lam2),1) - repmat(lam2,1,length(lam1));
    delta = min( abs(dif) );   % diffs from 33->65
    bigdel = (delta > 1e-12*norm(lam1,Inf));
    
    % Trim off things that are still changing a lot (relative to new size).
    lam1b = lam1; lam1b(bigdel) = 0;
    bigdel = logical((delta > 1e-3*norm(lam1b,Inf)) + bigdel);
    
    if all(bigdel)
        % All values changed somewhat--choose the one changing the least.
        [tmp,idx] = min(delta);
        sigma = lam1(idx);
    elseif numel(breaks) == 2 % Smooth
        % Of those that did not change much, take the smallest cheb coeff vector.
        lam1(bigdel) = [];
        V1 = reshape( V1, [33,m,size(V1,2)] );  % [x,varnum,modenum]
        V1(:,:,bigdel) = [];
        V1 = permute(V1,[1 3 2]);       % [x,modenum,varnum]
        C = zeros(size(V1));
        for j = 1:size(C,3)  % for each variable
            C(:,:,j) = abs( cd2cp(V1(:,:,j)) );  % cheb coeffs of all modes
        end
        mx = max( max(C,[],1), [], 3 );  % max for each mode over all vars
        [cmin,idx] = min( sum(sum(C,1),3)./mx );  % min 1-norm of each mode
        sigma = lam1(idx);
    else                      % Piecewise
        lam1(bigdel) = [];
        V1 = reshape( V1, [33,numints,m,size(V1,2)] );  % [x,interval,varnum,modenum]
        V1(:,:,:,bigdel) = [];
        V1 = permute(V1,[1 4 2 3]);       % [x,modenum,varnum]
        C = zeros(size(V1));
        for j = 1:size(C,4)  % for each variable
            for l = 1:numints
                C(:,:,l,j) = abs( cd2cp(V1(:,:,l,j)) );  % cheb coeffs of all modes
            end
        end
        mx = max( max( max(C,[],1), [], 3 ) , [], 4);  % max for each mode over all vars
        [cmin,idx] = min( sum(sum(sum(C,1),3),4)./mx );  % min 1-norm of each mode
        sigma = lam1(idx);
    end
end

% 'SM' is equivalent to eigenvalues nearest zero.
if strcmpi(sigma,'SM'), sigma = 0; end

% These assignments cause the nested function value() to overwrite them.
V = [];  D = [];  Nout = [];

% Default settings
settings = chebopdefaults;
settings.scale = A.scale;

% Adaptively construct the sum of eigenfunctions.
chebfun( @(x,N,bks) value_sys(x,N,bks), {breaks} , settings);
% Now V,D are already defined at the highest value of N used.

% Deal with finite rank linops
if size(D,1) < k
    if gotk
        warning('CHEBFUN:linop:eigs:rank',...
            'Input has finite rank, only %d eigenvalues returned.', size(D,1));
    end
    k = size(D,1);
end

if nargout < 2  % Return the eigenvalues
    varargout = { diag(D) };
else            % Unwrap the eigenvectors for output
    
    % Reshape so that each eigenfunc for each variable has its own column
    V = mat2cell(V(:),repmat(Nout,1,m*k),1);    
    
    Vfun = cell(1,m);                           % Initialise cell
    for l = 1:m, Vfun{l} = chebfun; end         % initialise chebfuns
    
    for kk = 1:k    % Loop over each eigenvector
        nrm2 = 0;
        for l = 1:m % Loop through the equations in the system
            tmp = chebfun;
            % Build a chebfun from the piecewise parts on each interval
            for j = 1:numel(breaks)-1
                V{1} = filter(V{1},1e-8); % These values haven't been filtered yet
                funj = fun( V{1}, breaks(j:j+1), settings);
                tmp = [tmp ; set(chebfun,'funs',funj,'ends',breaks(j:j+1),...
                    'imps',[funj.vals(1) funj.vals(end)],'trans',0)];
                V(1) = [];
            end
            % Simplify it
            tmp = simplify(tmp,settings.eps);
            Vfun{l}(:,kk) = tmp;
            nrm2 = nrm2 + norm(tmp)^2;
        end
        for l = 1:m % Normalise
            Vfun{l}(:,kk) = Vfun{l}(:,kk)/sqrt(nrm2);
        end
    end
    if m == 1, Vfun = Vfun{1}; end % Return a quasimatrix in this case
    varargout = { Vfun, D };
end

% Multiple outputs for system case.
if nargout > 2 && nargout == 1+length(varargout{1})
    % Allows [U V W ...  D] = eigs(L) for systems of equations
    % (which in some cases is preferred to cell array output)
    varargout = [ {varargout{1}{:}} varargout{2} ];
end

% END OF MAIN FUNCTION

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Called by the chebfun constructor. Returns values of the sum of the
% "interesting" eigenfunctions.
    function v = value_sys(y,N,bks)
        % y is a cell array with the points for each function.
        % N{j}(k) contains the # of pts for equation j on interval k.
        % bks{j}(k:k+1) is the ends of the interval j for equation k.
        if nargin == 1, v = y; return, end
        N = N{:};   bks = bks{:};     % Discretization size and breaks for all vars
        maxdo = max(A.difforder(:));  % The maximum derivative order of the system
        
        if m*sum(N) > maxdegree + 1
            error('LINOP:mldivide:NoConverge',['Failed to converge with ',int2str(maxdegree+1),' points.'])
        elseif any(N==1)
            error('LINOP:mldivide:OnePoint',...
                'Solution requested at a lone point. Check for a bug in the linop definition.')
        elseif any(N < maxdo+1)
            % Too few points: force refinement (This rarely happens)
            jj = find(N < maxdo+1); % Refine only where needed
            csN = [0 ; cumsum(N)];
            v = y;
            for ll = 1:length(jj)
                e = ones(N(jj(ll)),1); e(2:2:end) = -1;
                v{csN(jj(ll))+(1:N(jj(ll)))} = e;
            end
            return
        elseif sum(N) < k
            % Too few points: force refinement (This rarely happens)
            v = ones(size(y{1})); v(2:2:end) = -1;  v = {v};
            return
        end
        
        % Compute the eigenvalues of the discretised system
        [V,D] = bc_eig(A,B,N,k,sigma,map,bks);
        
        v = sum(reshape(V,[sum(N),size(V,2),m]),3);  % Combine equations
        v = sum(v,2);                                % Combine nodes
        
        % Filter
        csN = cumsum([0 N]);
        for jj = 1:numel(N)
            ii = csN(jj) + (1:N(jj));
            v(ii) = filter(v(ii),1e-8);
        end
        
        % Store these to be used by the wrapper function
        Nout = N;
        
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [V,D] = bc_eig(A,B,N,k,sigma,map,bks)
% Formulate the discrete problem and solve for the eigenvalues

m = A.blocksize(1);
numints = numel(bks)-1;
if numel(N) == 1, N = repmat(N,1,numints); end

if isempty(B) % Not generalised: [PA ; BC]*v = lambda*[P ; 0]*v
    
    % Evaluate the matrix A at size N with boundary conditions attached
    [Amat,ignored,c,ignored,P] = feval(A,N,'bc',map,bks);
    
    % Recover the global projection matrix 
    if m == 1
        Pmat = [P ; zeros(numel(c),sum(N)*m)];
    else
        Pmat = zeros(sum(N)*m);
        i1 = 0; i2 = 0;
        for j = 1:A.blocksize(1)
            ii1 = i1+(1:size(P{j},1));
            ii2 = i2+(1:size(P{j},2));
            Pmat(ii1,ii2) = P{j};
            i1 = ii1(end); i2 = ii2(end);
        end
    end
    
    % Compute the generalised eigenvalue problem.
    [V,D] = eig(full(Amat),full(Pmat));
    
else % Generalised: [PA ; BC]*v = lambda*[P*B ; 0]*v
    
    % Force difforder to be the same, so that projection P is the same.
    do = max(A.difforder, B.difforder);
    A.difforder = do; B.difforder = do;
    
    % Evaluate the matrix A and B at size N with boundary conditions attached
    Amat = feval(A,N,'bc',map,bks);
    Bmat = feval(B,N,'bc',map,bks);
    
    % Square up matrices if # of boundary conditions is not the same.
    sizediff = size(Amat,1)-size(Bmat,1);
    Amat = [Amat ; zeros(-sizediff,size(Amat,2))];
    Bmat = [Bmat ; zeros(sizediff,size(Bmat,2))];
    
    % Compute the generalised eigenvalue problem.
    [V,D] = eig(full(Amat),full(Bmat));
    
end
% Find the droids we're looking for.
idx = nearest(diag(D),V,sigma,min(k,N),N);
V = V(:,idx);
D = D(idx,idx);

% Complain if there aren't enough.
%     if size(V,2) < k
%         % Matrix wasn't big enough
%         v = ones(size(V,1),1); v(2:2:end) = -1;
%         V = [V repmat(v,1,k-size(V,2))];
%     end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns index vector that sorts eigenvalues by the given criterion.
function idx = nearest(lam,V,sigma,k,N)

if isnumeric(sigma)
    if isinf(sigma)
        [junk,idx] = sort(abs(lam),'descend');
    else
        [junk,idx] = sort(abs(lam-sigma));
    end
else
    switch upper(sigma)
        case 'LR'
            [junk,idx] = sort(real(lam),'descend');
        case 'SR'
            [junk,idx] = sort(real(lam));
        case 'LI'
            [junk,idx] = sort(imag(lam),'descend');
        case 'SI'
            [junk,idx] = sort(imag(lam));
        case 'LM'
            [junk,idx] = sort(abs(lam),'descend');
            % case 'SM' already converted to sigma = 0
        otherwise
            error('CHEBFUN:linop:eigs:sigma', 'Unidentified input ''sigma''.');
    end
end

% Delete infinite values. These can arise from rank deficiencies in the
% RHS matrix of the generalized eigenproblem.
idx( ~isfinite(lam(idx)) ) = [];

% Propose to keep these modes.
queue = 1:min(k,length(idx));
keeper = false(size(idx));
keeper(queue) = true;

%%
% Screen out spurious modes. These are dominated by high frequency for all
% values of N. (Known to arise for some formulations in generalized
% eigenproblems, specifically Orr-Sommerfeld.)

% Grab some indices
tenPercent = ceil(N/10); % We are the 10%
iif10 = 1:tenPercent;    % Indices of first 10%
ii90 = tenPercent:N;     % Indices of last 90%
ii10 = (N-tenPercent):N; % Indices of last 10%

% % First an arbitrary linear combination of the allowed vectors
% VV = V(:,idx)*[1 ; 2 + sin(1:size(idx,2)-1).']; % Form linear combination
% if numel(N) == 1
%     vc = cd2cp(VV);
% else
%     vc = zeros(max(N),1);
%     csN = cumsum([0 N]);
%     for jj = 1:numel(N)
%         % We can save time (and FFTs) by combining intervals which
%         % have the same discretisation length (say, N(i) = N(j)). TODO.
%         ii = csN(jj) + (1:N(jj)).';
%         tmp = cd2cp(V(ii));
%         vc(1:N(jj)) = vc(1:N(jj))+tmp(end:-1:1);
%     end
%     vc = vc(end:-1:1);
% end
% norm90 = norm(vc(ii90)); % Norm of last 90%
% norm10 = norm(vc(ii10)); % Norm of last 10%
% if norm10 <= 0.5*norm90    
%     % We don't need to bother checking each of the vectors for high energy
%     % as their sum passes OK!
%     idx = idx( keeper ); % Return the keepers.
% end

lenV = size(V);
sumN = sum(N);
if ( lenV > sumN )
    numVars = lenV/sumN;
    if ( round(numVars) ~= numVars )
        error('Oops.');
    end
    VNew = V(1:sumN, :);
    for j = 1:numVars-1
        VNew = VNew + V(j*sumN + (1:sumN), :);
    end
    V = VNew;
end

% Check for high frequency energy (indicative of spurious eigenvalues) in
% each of the remaining valid eigenfunctions.
while ~isempty(queue)
    j = queue(1);
    
    if numel(N) == 1
        vc = cd2cp(V(:,idx(j)));
    else
        vc = zeros(max(N),1);
        csN = cumsum([0 N]);
        for jj = 1:numel(N)
            % We can save time (and FFTs) by combining intervals which
            % have the same discretisation length (say, N(i) = N(j)). TODO.
            ii = csN(jj) + (1:N(jj)).';
            tmp = cd2cp(V(ii,idx(j)));
            vc(1:N(jj)) = vc(1:N(jj))+tmp(end:-1:1);
        end
        vc = vc(end:-1:1);
    end
    vc = abs(vc);
    
    % Recipe: More than half of the energy in the last 90% of the Chebyshev
    % modes is in the highest 10% modes, and the energy of the last 90% is
    % not really small (1e-8) compared to the first 10% (i.e. is not noise).
    norm90 = norm(vc(ii90)); % Norm of last 90%
    norm10 = norm(vc(ii10)); % Norm of last 10%
    normfirst10 = norm(vc(iif10)); % Norm of first 10%
    if ( norm10 > 0.5*norm90 && norm90 > 1e-8*normfirst10 )
        keeper(j) = false;
        if queue(end) < length(idx)
            m = queue(end)+1;
            keeper(m) = true;  
            queue = [queue(:); m];
        end
    end
    queue(1) = [];
    
end

%%

% Return the keepers.
idx = idx( keeper );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = cd2cp(y)
%CD2CP  Chebyshev discretization to Chebyshev polynomials (by FFT).
%   P = CD2CP(Y) converts a vector of values at the Chebyshev extreme
%   points to the coefficients (ascending order) of the interpolating
%   Chebyshev expansion.  If Y is a matrix, the conversion is done
%   columnwise.

p = zeros(size(y));
if any(size(y)==1), y = y(:); end
N = size(y,1)-1;

yhat = fft([y(N+1:-1:1,:);y(2:N,:)])/(2*N);

p(2:N,:) = 2*yhat(2:N,:);
p([1,N+1],:) = yhat([1,N+1],:);

if isreal(y),  p = real(p);  end

end