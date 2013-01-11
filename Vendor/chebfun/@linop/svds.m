function varargout = svds(A,k,sigma,tol)
%SVDS  Find some singular values and vectors of a compact linop.
% S = SVDS(A) returns a vector of 6 nonzero singular values of the linear
% compact chebop A, such as the FRED or VOLT operator. SVDS will attempt to
% return the largest singular values. If A is not linear, an error is
% returned.
%
% [U,S,V] = SVDS(A) returns a diagonal 6x6 matrix D and two orthonormal
% quasi-matrices such that A*V = U*S.
%
% Note that an integral operator smoothest the right-singular vectors V.
% Hence finding these vectors is a problem with possibly large backward
% errors and one must expect that the vectors in V are not accurate to
% machine eps. However, the left sing. vectors U have fine accuracy.
%
% Example:
% d = domain(0,pi);
% A = fred(@(x,y)sin(2*pi*(x-2*y)),d);
% [U,S,V] = svds(A);
%
% SVDS(A,K) computes the K largest singular values of A.
%
% SVDS(A,K,SIGMA) tries to compute K singular values closest to a scalar
% shift SIGMA. (Note, for compact operators there are infinitely many
% singular values close to or at zero!).
%
% See also linop/eigs, linop/null.
%
% Please note that SVDS is considered experimental. As such, it does not
% yet support systems of equations, or those containing piecewise operators
% or breakpoints.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

dom = domain(A);
nbc = A.numbc;
if nargin < 2, k = 6; end;
if nbc == 0 && (nargin < 3 || isempty(sigma) || strcmp(sigma,'L')), sigma = inf; end;
if nbc > 0 && (nargin < 3 || isempty(sigma) || strcmp(sigma,'S')), sigma = 0; end;
svds_nargout = nargout; % to be available in nested function


% Setup
if nargin < 4, tol = 1e-10; end
pref = chebfunpref;
pref.eps = tol;
Sold = -inf;
% split = chebfunpref('splitting');
split = false;
maxdegree = cheboppref('maxdegree');
syssize = A.blocksize(1);
m = A.blocksize(2);
breaks = dom.endsandbreaks;
numints = numel(breaks)-1;
bcs = false;
if numints > 1 || nbc > 1, bcs = true; end
Nout = [];

% if syssize > 1
%     error('CHEBFUN:svds:systems',...
%         'SVDS does not yet support systems of equations.');
% end
if m ~= A.blocksize(1)
    error('LINOP:svds:notsquare','Block size must be square.')
end

% if numints > 1
%     error('CHEBFUN:svds:piecewise',...
%         'SVDS does not yet support piecewise operators.');
% end

% This shouldn't happen, but we might as well deal with it.
if isnan(k) || isempty(k), k = 6; end

% These assignments cause the nested function value() to overwrite them.
U = []; S = []; V = []; flag = 0; pts = [];  Minv = []; D = [];

% Default settings
settings = chebopdefaults;
settings.scale = A.scale;
settings.eps = tol;
settings.minsamples = 5;

% Adaptively construct the sum of eigenfunctions.
if numel(breaks) == 2 && ~split
    chebfun( @(x) value(x), dom, settings);
else
    chebfun( @(x,N,bks) value_sys(x,N,bks), {breaks} , settings);
end
% Now U,S,V are already defined at the highest value of N used.



if numel(breaks) == 2
    if syssize == 1
        U = Minv*(diag(1./D)*U);
        U = simplify(chebfun(U,dom),tol);
        V = Minv*(diag(1./D)*V);
        V = simplify(chebfun(V,dom),tol);
    else
        MiD = Minv*spdiags(1./D,0,pts,pts);
        UU = cell(syssize,1); VV = cell(syssize,1);
        for k = 1:syssize
            UU{k} = MiD*U((k-1)*pts+(1:pts),:);
            UU{k} = chebfun(UU{k},dom);
            UU{k} = simplify(UU{k},tol);
            VV{k} = MiD*V((k-1)*pts+(1:pts),:);
            VV{k} = chebfun(VV{k},dom);
            VV{k} = simplify(VV{k},tol);
        end
        U = UU; V = VV;
    end
else
    N = Nout;
    V = MiD*V;
    U = MiD*U;
    V = mat2cell(V(:),repmat(N,1,m*k),1);
    U = mat2cell(U(:),repmat(N,1,m*k),1);

    Vfun = cell(1,m);
    Ufun = cell(1,m);
    for l = 1:m, 
        Vfun{l} = chebfun; 
        Ufun{l} = chebfun; 
    end % initialise
    settings.maxdegree = maxdegree;  settings.maxlength = maxdegree;
    
    for kk = 1:k % Loop over each pair of singvecs
        nrm2v = 0; nrm2u = 0;
        for l = 1:m % Loop through the equations in the system
            tmpv = chebfun; 
            tmpu = chebfun; 
            % Build a chebfun from the piecewise parts on each interval
            for j = 1:numel(breaks)-1
                funj = fun( filter(V{1},1e-8), breaks(j:j+1), settings);
                tmpv = [tmpv ; set(chebfun,'funs',funj,'ends',breaks(j:j+1),...
                    'imps',[funj.vals(1) funj.vals(end)],'trans',0)];
                V(1) = [];
                funj = fun( filter(U{1},1e-8), breaks(j:j+1), settings);
                tmpu = [tmpu ; set(chebfun,'funs',funj,'ends',breaks(j:j+1),...
                    'imps',[funj.vals(1) funj.vals(end)],'trans',0)];
                U(1) = [];               
            end
            % Simplify it
            tmpv = simplify(tmpv,settings.eps);
            tmpu = simplify(tmpu,settings.eps);
            Vfun{l}(:,kk) = tmpv;
            Ufun{l}(:,kk) = tmpu;
            nrm2v = nrm2v + norm(tmpv)^2;
            nrm2u = nrm2v + norm(tmpu)^2;
        end
        for l = 1:m % Normalise
            Vfun{l}(:,kk) = Vfun{l}(:,kk)/sqrt(nrm2v);
            Ufun{l}(:,kk) = Ufun{l}(:,kk)/sqrt(nrm2u);
        end
    end
    if m == 1, 
        Vfun = Vfun{1}; 
        Ufun = Ufun{1}; 
    end % Return a quasimatrix in this case
    V = Vfun;
    U = Ufun;
    
end

if nargout <= 1,
    varargout = { S };
else
    varargout = { U,diag(S),V, flag };
end

    function u = value(x)
        
        if numel(x) > maxdegree/2+1,
            if svds_nargout < 4,
                warning('chebfun:linop:svds','Left singular vectors not resolved to machine precision.');
            end
            flag = 1;
            u = 0*x;
            return;
        end
        
        % Size of current discretisation
        pts = numel(x);
        % Legendre to Chebyshev projection and quadrature matrices
        [M,D,Minv] = getL2InnerProductMatrix(pts,dom);
        
        % Get collocation matrix
        if nbc > 0 % Construct a square matrix with bc's
            %[Amat ignored ignored ignored P] = feval(A,pts,'bc');
            %[ignored,B,ignored,ignored,ignored,Amat] = feval(A,pts,'bc',[],bks);
            [ignored,B,ignored,ignored,ignored,Amat] = feval(A,pts,'bc');
        else       % a square matrix with no boundary conditions
            [Amat ignored ignored ignored P] = feval(A,pts,'nobc');
        end
        
        if diff(size(Amat)),
            error('chebfun:linop:svds','Nonsquare collocation currently not supported.')
        end
        
        if syssize == 1
            

                Amat = full(spdiags(D,0,pts,pts)*M)*Amat*full(Minv*spdiags(1./D,0,pts,pts));
                [U,S,V] = svd(full(Amat));
                S = diag(S);

            
        else
            
            % Make block versions of the projection and quadrature matrices
            DM1 = spdiags(D,0,pts,pts)*M;
            DM = repmat({DM1},1,syssize);
            DM = blkdiag(DM{:});
            MiD1 = Minv*spdiags(1./D,0,pts,pts);
            MiD = repmat({MiD1},1,syssize);
            MiD = blkdiag(MiD{:});
            

                Amat = full(DM*Amat*MiD);
                [U,S,V] = svd(Amat);
                S = diag(S);

        end
        
        % Sort and truncate
        S = S(S>tol/10*S(1)); % ignore these, as singular vectors are noisy
        [dummy,ind] = sort(abs(sigma - S),'ascend'); % singvals closest to sigma
        ind = ind(1:min(k,length(ind)));
        ind = sort(ind);
        V = V(:,ind);
        U = U(:,ind);
        S = S(ind);
        
        % If S is not acceptable, then return sawtooth to increase N.
        if length(S) ~= length(Sold) || isempty(S)
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        elseif norm((S-Sold)./S(1),inf) > tol,
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        else
            Sold = S;
        end
        
        coef = [1, 2+sin(1:length(ind)-1)]';  % Form a linear combination of variables
        u = U*coef; % Collapse to one vector (See LINOP/MLDIVIDE for more details)
        MiD = repmat(Minv*spdiags(1./D,0,pts,pts),1,syssize);
        u = MiD*u; % Convert to L2-orthonormal Chebyshev basis
        u = filter(u,100*tol);
        
        u = filter(u,1e-8);
        
    end

    function u = value_sys(x,N,bks)
        % y is a cell array with the points for each function.
        % N{j}(k) contains the # of pts for equation j on interval k.
        % bks{j}(k:k+1) is the ends of the interval j for equation k.
        x = x{:}; N = N{:}; bks = bks{:};
        if numel(N) == 1, N = repmat(N,1,numints); end
        
        if numel(x) > maxdegree/2+1,
            if svds_nargout < 4,
                warning('chebfun:linop:svds','Left singular vectors not resolved to machine precision.');
            end
            u = 0*x;
            flag = 1;
            return;
        end

        % Evaluate the Matrix with boundary conditions attached
        [Amat,ignored,c,ignored,P] = feval(A,N,'bc',[],bks);
        
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
        
        M = []; D = []; Minv = [];
        for kk = 1:numel(N)
            [Mk,Dk,Minvk] = getL2InnerProductMatrix(N(kk),bks(kk:kk+1));
            M = blkdiag(M,Mk);
            D = [D ; Dk];
            Minv = blkdiag(Minv,Minvk);
        end

        % Make block versions of the projection and quadrature matrices
        DM1 = diag(D)*M;
        DM = repmat({DM1},1,syssize);
        DM = blkdiag(DM{:});
        MiD1 = Minv*diag(1./D);
        MiD = repmat({MiD1},1,syssize);
        MiD = blkdiag(MiD{:});
            
%         P = blkdiag(P{:});
        B = [P ; zeros(size(Amat,1)-size(P,1),size(P,2))];
        Amat = DM*(Amat\B)*MiD;
        [U,Sinv,V] = svd(full(Amat));
        S = 1./diag(Sinv);
                
        % Sort and truncate
        S = S(S>tol/10*S(1)); % ignore these, as singular vectors are noisy
        [dummy,ind] = sort(abs(sigma - S),'ascend'); % singvals closest to sigma
        ind = ind(1:min(k,length(ind)));
        ind = sort(ind);
        V = V(:,ind);
        U = U(:,ind);
        S = S(ind);

        
        % If S is not acceptable, then return sawtooth to increase N.
        if length(S) ~= length(Sold) || isempty(S)
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        elseif norm((S-Sold)./S(1),inf) > 1e7,
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        else
            Sold = S;
        end

        u = sum(reshape(U,[sum(N),size(U,2),m]),3);  % Combine equations
        u = sum(u,2);                        % Combine nodes

        % Filter
        csN = cumsum([0 N]);
        for jj = 1:numel(N)
          ii = csN(jj) + (1:N(jj));
          u(ii) = filter(u(ii),1e-6);
        end
%         plot(x,MiD*U(:,1),'.-',x,MiD*V(:,1),'or')
%         pause
        
        u = {u};  

        % Store these to be used by the wrapper function
        Nout = N;

    end
end







function [M,D,Minv] = getL2InnerProductMatrix(pts,d)
% Returns matrices M,Minv such that for two vectors x,y of
% length pts we have
% y'*x = chebfun(diag(D)*M*y)'*chebfun(diag(D)*M*x).
% Minv is the inverse of M.

x = chebpts(pts,d);
[y,w,v] = legpts(pts,d);
M = barymat(y,x);
D = sqrt(w(:));
Minv = barymat(x,y,v);
end



