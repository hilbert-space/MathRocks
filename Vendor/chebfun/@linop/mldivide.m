function C = mldivide(A,B,varargin)
% \  Solve a linear operator equation.
% U = A\F solves the linear system A*U=F, where U and F are chebfuns and A
% is a linop. If A is a differential operator of order M, a warning will
% be issued if A does not have M boundary conditions. In general the
% function may not converge in this situation.
%
% The algorithm is to realize and solve finite linear systems of increasing
% size until the chebfun constructor is satisfied with the convergence.
% This convergence is in a relative sense for U, which may not be
% appropriate in some situations (e.g., Newton's method finding a small
% correction). To set a different scale S for the relative accuracy, use
% A.scale = S before solving.
%
% EXAMPLE
%   % Newton's method for (u')^2+6u=1, u(0)=0.
%   d = domain(0,1);  D = diff(d);
%   f = @(u) diff(u).^2 - 6*u - 1;
%   J = @(u) (diag(2*diff(u))*D - 6) & 'dirichlet';
%   u = chebfun('x',d);  du = Inf;
%   while norm(du) > 1e-12
%     r = f(u);  A = J(u);  A.scale = norm(u);
%     du = -(A\r);
%     u = u+du;
%   end

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

maxdegree = cheboppref('maxdegree');
if nargin >2, tolerance = varargin{1}; end
persistent storage
if isempty(storage), storage = struct('L',[],'U',[],'P',[],'c',[],'p',[]); end
use_store = cheboppref('storage');

switch(class(B))
    case 'linop'
        %TODO : Experimental, undocumented.
        dom = domaincheck(A,B);
        C = linop( A.varmat\B.varmat, [], dom, B.difforder-A.difforder );
        
    case 'double'
        if length(B)==1  % scalar expansion
            B = repmat(B,1,A.blocksize(1));
            %     else
            %       error('LINOP:mldivide:operand','Use scalar or chebfun with backslash.')
        end
        for k = 1:numel(B)
            Bcheb(:,k) = chebfun(B(k),domain(A),chebopdefaults);
        end
        C = mldivide(A,Bcheb,varargin{:});
        
    case 'chebfun'
        dom = domaincheck(A,B(:,1));
        m = A.blocksize(2);
        
        % Grab the default settings.
        settings = chebopdefaults;
        if nargin > 2
            settings.eps = tolerance;
        end
        
        % Take the union of all the ends.
        ends = dom.endsandbreaks;
        for k = 1:numel(B)
            ends = union(B(:,k).ends,ends);
        end
        
        % Deal with maps.
        % TODO : test this.
        map = mapcheck(get(B(:,1),'map'),get(B(:,1),'ends'),1);
        if ~isempty(map)
            settings.map = map;
        end
        
        % Can't do this yet.
        if ~isempty(map) && numel(map)~=numel(ends)-1
            warning('CHEBFUN:linop:mldivide:mapbreaks',...
                'New breakpoint introduced, so map data from RHS is ignored.');
            map = [];
        end
        
        V = [];  % Initialise V so that the nested function overwrites it.
        syssize = A.blocksize(1);     % Number of eqns in system.
        coef = [1, 1 + .5*sin(1:A.blocksize(2)-1)];  % for a linear combination of variables
        
        % Enforce required conditions on an unbounded integro-equation
        infdom = isinf(isinf(ends));
        if syssize == 1 && all(A.difforder) == -1 && (any(infdom) || (isempty(A.lbc) && isempty(A.rbc)))
            bc = struct('left',struct([]),'right',struct([]));
            I = eye(domain(ends));
            if infdom(end)
                bc.right = struct('op',I,'val',0);
                if infdom(1)
                    bc.left = struct('op',I,'val',0);
                end
            else
                bc.left = struct('op',I,'val',0);
            end
            A = setbc(A,bc);
        end
        
        % Diagonal problem --> Division operator.
        if ~any(any(A.difforder)) && all(all(A.isdiag))
            if A.numbc > 0
                warning('LINOP:mldivide:bcnum',...
                    'Operator may not have the correct number of boundary conditions.')
            end
            C = B./diag(A);
            return
        end
        
        % Deal with parameter dependent problems
        paridx = min(A.isdiag,[],1) == 1;
        funidx = find(~paridx);     paridx = find(paridx);
        nfun = numel(funidx);       npar = numel(paridx);
        
        if sum(max(A.difforder,[],1)) ~= sum(max(A.difforder,[],2))
            warning('LINOP:mldivide:hell',...
                'This equation may be solved incorrectly. See Trac #202.')
        elseif A.numbc-npar-size(A.jumpinfo,1) ~= sum(max(A.difforder,[],2))
            warning('LINOP:mldivide:bcnum',...
                'Operator may not have the correct number of boundary conditions.')
        end
        
        % Look for ill conditioning that may indicate an ill posed problem.
        Amat = feval(A,20);  % keep it small
        warnstate = warning('query','all');
        warning('off','MATLAB:singularMatrix');
        warning('off','MATLAB:nearlySingularMatrix');
        if length(Amat) < 300
            if (npar == 0 && (size(Amat,1)~=size(Amat,2) || cond(Amat,1) > 0.01/eps)) || ...
                    (npar>0 && cond(Amat,2) > 0.01/eps)
                warning('linop:mldivide:illposed',...
                    'Problem may be ill-posed. Check the boundary conditions.')
            end
        end
        warning(warnstate);  % restore old warning state

        if ~npar && diff(A.blocksize)
            warning('CHEBFUN:mldivide:notsquare',...
                'Operator does not appear to be square.');
        end
        if numel(B) ~= syssize
            error('CHEBFUN:mldivide:rhssize',...
                'Inconsistent system size. Check RHS?');
        end
        
        % ODEs with delta functions on the RHS
        % Are there any impulses in B?
        % if B is a column chebfun and there are possible delta functions
        if( size(B,2) < 2 && size( B.imps, 1 ) >= 2 && any(abs(B.imps(2,:))>100*eps) )
            loc = abs(B.imps(2,:))>100*eps; % find location of delta functions.
            deltaLoc = B.ends(loc);
            A.domain = dom;
            ndelta = length(deltaLoc);
            deltaMag = B.imps(2, loc);      % magnitude of delta functions
            if( ~isempty( deltaLoc ) )
                % evaluate the highest coefficient of A at delta locations
                % all coefficents are returned as chebfuns in ANX
                anx = recoverCoeffs(A);
                % retain the highest order coefficent
                anx = anx(:, end);
                % evaluate this coefficent at delta locations
                anx = anx(deltaLoc);
                if(any(abs(anx)<100*eps))
                    error('linop:mldivide:delta function at a singular point of the ODE');
                else
                    jumpVal = deltaMag./anx;
                    n = A.difforder;
                    if(isempty(A.bc))
                        A.bc = struct('op',[],'val',[]);
                        bcIdx = 1;
                    else
                        bcIdx = length(A.bc)+1;
                    end
                    
                    for k = 1:ndelta;
                        % impose a jump in the (n-1)st derivative, continuity upto
                        % (n-2)nd derivative is done automatically
                        Jk = (feval(dom,deltaLoc(k),'right') - feval(dom,deltaLoc(k),'left'))*diff(dom,n-1);
                        A.bc(bcIdx+k-1).op = Jk;
                        A.bc(bcIdx+k-1).val = jumpVal(k);
                        A.numbc = A.numbc+1;
                        A.jumpinfo = [A.jumpinfo; [deltaLoc(k) 1 n-1]];
                    end
                    
                    % Ignore delta functions at end points (Experimental!)
                    if(abs(deltaLoc(1)-dom(1)) < 100*eps )
                        % discard delta function at the left end point
                        % of the domain
                        A.bc(bcIdx) = [];
                        A.numbc = A.numbc - 1;
                        A.jumpinfo(end) = [];
                    end
                    
                    % deal with a delta at the right end point
                    if(abs(deltaLoc(end)-dom(2)) < 100*eps )
                        % discard delta function at the right end point
                        % of the domain
                        A.bc(end) = [];
                        A.numbc = A.numbc - 1;
                        A.jumpinfo(end) = [];
                    end
                    
                end
            end
        end
        
        
        if isa(A.scale,'function_handle')
            A.scale = chebfun(A.scale,ends);
        end
        if isa(A.scale,'chebfun')
            warning('CHEBFUN:linop:mldivide:sclfun', ...
                'No support for function scaling for piecewise domains.')
            C = chebfun( @(x,N,bks) A.scale(x) + value(x,N,bks), ...
                {ends}, settings) - A.scale;
        else
            settings.scale = A.scale;
            C = chebfun( @(x,N,bks) value(x,N,bks), {ends}, settings);
        end
        
        % If there aren't systems, then we're done.
        if m == 1, C = C{:}; return, end
        
        % V has been overwritten by the nested value function.
        % We need to simplify it and store as the output.
        C = chebfun; % Will contain the output.
        for j = 1:m  % For each variable, build a chebfun.
            tmp = chebfun;          % Temporary chebfun for the jth variable.
            for k = 1:numel(ends)-1 % Loop over each subinterval.
                funk = fun( V{1}, ends(k:k+1), settings);
                tmp = [tmp ; set(chebfun,'funs',funk,'ends',ends(k:k+1),...
                    'imps',[funk.vals(1) funk.vals(end)],'trans',0)];
                V(1) = [];
            end
            C(:,j) = simplify(tmp,settings.eps); % Simplify and store.
        end
        
    otherwise
        error('LINOP:mldivide:operand','Unrecognized operand.')
        
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
        
        % We don't use storage in these situations
        if numel(N) > 1 || N <=4 || ~isempty(map) || (~isempty(bks)&&length(bks)~=2) || ~isempty(paridx)
            use_store = 0;
        end
        
        haveLU = false;
        % Check to see if the matrix has LU factors stored in cache
        if use_store && length(storage)>=A.ID && length(storage(A.ID).L)>=N && ~isempty(storage(A.ID).L{N})
            % It does!
            L = storage(A.ID).L{N};
            U = storage(A.ID).U{N};
            P = storage(A.ID).P{N};
            c = storage(A.ID).c{N};
            p = storage(A.ID).p{N};
            Dl = storage(A.ID).Dl{N};
            haveLU = true;
            
        else% If not, then make it.
            
            % Evaluate the matrix with boundary conditions attached.
            [Amat,ignored,c,ignored,P,Amat2] = feval(A,N,'bc',map,bks);
            if ~iscell(P), P = {P}; end
            
            if use_store
                % This is very crude garbage collection!
                % If size is exceeded, wipe out everything.
                ssize = whos('storage');
                if ssize.bytes > cheboppref('maxstorage')
                    storage = struct([]);
                end
                dd = 1./max(abs(Amat),[],2);
                Dl = spdiags(dd,0,size(Amat,1),size(Amat,1));
                [L U p] = lu(Dl*Amat,'vector');
                storage(A.ID).L{N} = L;
                storage(A.ID).U{N} = U;
                storage(A.ID).P{N} = P;
                storage(A.ID).c{N} = c;
                storage(A.ID).p{N} = p;
                storage(A.ID).Dl{N} = Dl;
                haveLU = true;
            end
        end
        
        % Deal with parameter dependent problems
        if ~isempty(paridx)
            ii = [];  nbc = numel(c); bc = zeros(nbc,npar); % initialise
            for kk = 1:npar                                 % cols to remove
                iik = sN*(paridx(kk)-1)+1:sN*paridx(kk);
                bc(:,kk) = sum(Amat(end-nbc+1:end,iik),2);
                ii = [ii iik];
            end
            % Remove parameter columns from Amat
            Amat(:,ii) = [];  Amat2 = Amat2(:,ii);
            % Colapse them each onto a single col and add back to Amat
            if syssize == 1 && npar == 1 % Easy case
                Acol = P{1}*diag(Amat2);
            else                         % Tricker case (systems, #params > 1)
                Acol = []; idx = 1:(syssize*sN+1):(syssize*sN^2);
                for kk = 1:npar % Project the diagonals of each of the parameters subblocks
                    Acolkk = []; idxj = idx;
                    for jj = 1:syssize
                        Acolkk = [Acolkk ; P{jj}*Amat2(idxj).'];
                        idxj = idxj+sN;
                    end
                    Acol = [Acol Acolkk];
                    idx = idx + syssize*sN^2;
                end
            end
            Amat = [Amat [Acol ; bc]]; % Reform the big matrix with the new columns augmented
        end
        
        % The RHS.
        f = [];
        % Project the RHS.
        if ~any(isinf(bks))
            for jj = 1:syssize, f = [f ; B(P{jj}*y{1},jj)]; end
        else
            for jj = 1:syssize
                Bj = B(y{1},jj);
                Bj(csN(2:end),:) = B(bks(2:end),jj,'left');
                Bj(csN(1:end-1)+1,:) = B(bks(1:end-1),jj,'right');
                f = [f ; P{jj}*Bj];
            end
        end
        
        % Add boundary conditions.
        f = [f ; c];
        
        % Solve the system.
        if ~haveLU
            %        v = Amat\f;
            dd = 1./max(abs(Amat),[],2);
            Dl = spdiags(dd,0,size(Amat,1),size(Amat,2));
            v = (Dl*Amat) \ (Dl*f);
        else
            dlf = Dl*f;
            v = U\(L \ dlf(p) );
        end
        
        % Store V for output.
        if any(paridx)
            % Recover parameters (some effort required to get in correct order)
            V = [mat2cell(v(1:end-npar,1),repmat(N,1,numel(funidx)),1)                        % funs
                reshape(repmat(num2cell(v(end-npar+1:end))',numel(N),1),npar*numel(N),1)];   % params
            V = reshape(V,numel(N),numel(V)/numel(N));
            [ignored resort] = sort([funidx paridx]); V = V(:,resort);  % Resort
            v = v(1:end-npar,1);                                        % Remove params from v
        else
            V = mat2cell(v,repmat(N,1,A.blocksize(2)),1);
        end
        
        v = reshape(v,[sN,numel(funidx)]);        % one variable per column
        % Need to return a single function to test happiness. If you just sum
        % functions, you get weird results if v(:,1)=-v(:,2), as can happen in
        % very basic problems. We just use an arbitrary linear combination (but
        % the same one each time!).
        v = v*coef(1:nfun).';
        
        % Filter
        for jj = 1:numel(N)
            ii = csN(jj) + (1:N(jj));
            v(ii) = filter(v(ii),1e-13);
        end
        
        v = {v};                                % Output as cell array.
        
    end

end


function [p varargout] = recoverCoeffs(L)
%RECOVERCOEFFS  Recover coefficient functions of a linear operator
% P = RECOVERCOEFFS(L) returns, for a linear operator L, a chebfun
% quasimatrix P such that
%         Lu = P(:,1)*u + P(:,2)*u' + P(:,3)*u" + ... P(:,M+1)*u^(M),
% where M is the difforder of the operator. If L is not linear, an error is
% thrown.
%
% For a block operator L, i.e., one defining a system of equations
%         Lu = [L_{1,1} L_{1,2} ... L_{1,S}] [ u_1 ]
%              [L_{2,1} L_{1,2} ... L_{1,S}] [ u_2 ]
%              [  ...     ...   ...   ...  ] [ ... ]
%              [L_{R,1} L_{R,2} ... L_{R,S}] [ u_S ],
% P will be the RxS cell array such that P{J,K} = RECOVERCOEFFS(L_{J,K}).
%
% [P L] = RECOVERCOEFFS(L) returns also the linop L, which can be useful if
% the input was a linear chebop.
%
% Example 1:
%  [L x] = chebop(@(x,u) 0.5*diff(u,2) - sin(x).*diff(u) + x.*u);
%  p = recoverCoeffs(L)
%  norm(p - [x -sin(x) 0.5])
%
% Example 2:
%  [L x] = chebop(@(x,u) diff(sin(x).*(diff(cos(x).*u))),[-pi pi]);
%  p = recoverCoeffs(L)
%  norm(p - [-sin(2*x) 1-3*sin(x).^2 sin(2*x)/2])
%
% Example 3:
%  L = chebop(@(x,u,v) [diff(u,2), 0.5*diff(v)+exp(x)]);
%  p = recoverCoeffs(L)
%  norm([p{:}] - [0 0 1 0 0 0 .5])

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Convert to linop if input is a chebop. (But don't overwrite input as it's
% more efficient to evaluate the chebop .op than the linearised .oparray!)
if isa(L,'chebop'), L2 = linop(L); else L2 = L; end

% Initialise
s = L2.blocksize;                % Determine the size of the system
m = L2.difforder;                %  and the difforder
x = chebfun(@(x)x,L2.domain,2);  % faster than the line below.
% x = chebfun('x',L2.domain,2);    % Construct linear function on the domain
x0 = chebfun(0,L2.domain);       %  and the zero function
p = cell(s);                     % Initialise output
p0 = L*repmat(x0,1,s(2));        % Compute non-autonomous component

% The main routine
for hh = 1:s(2)                 % Loop over each of the dependant variables
    x0l = repmat(x0,1,hh-1);    % Set dep vars to the left to zero
    x0r = repmat(x0,1,s(2)-hh); % Set dep vars to the right to zero
    p1 = L*[x0l 1+0*x x0r];     % Evaluate all equations for [0 ... 1 ...0]
    p1 = p1 - p0;               % Subtract non-autonomous component
    for ll = 1:s(1)             % Loop over equations and assign
        p{ll,hh} = p1(:,ll);
    end
    xk = x;                            % Update indep var to x
    for kk = 1:max(m(:,hh))            % Loop over each x^k
        tmp = L*[x0l xk(:,kk) x0r]-p0; % Evaluate for u = [0 ... x^k ... 0]
        for ll = 1:s(1)                % Loop over each equation
            if kk > m(ll,hh), continue, end % No coeffs of this order here
            p{ll,hh}(:,kk+1) = tmp(:,ll);   % Assign the ll-th equation
            for jj = 1:kk              % Extract the lower-order terms
                p{ll,hh}(:,kk+1) = p{ll,hh}(:,kk+1) - p{ll,hh}(:,kk+1-jj).*xk(:,jj);
                p{ll,hh}(:,kk+1) = simplify(p{ll,hh}(:,kk+1)); % Simplify
            end
        end
        xk = [xk x.*xk(:,end)/(kk+1)]; % Update indep var to x^k/k!
    end
end

% Tidy the output
if max(s) == 1, p = p{:}; end          % Output quasimatrix if not a system
if nargout == 2, varargout{1} = L; end % Output the linop if required
end