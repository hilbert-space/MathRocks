function [Q,R] = qr(A,econ)   
% QR   QR factorization of a column quasimatrix.
%
% [Q,R] = QR(A) or QR(A,0), where A is a column quasimatrix with n
% columns, produces a column quasimatrix Q with n orthonormal columns
% and an n x n upper triangular matrix R such that A = Q*R.
%
% If the quasimatrix A contains no exponents or non-linear maps, the
% columns of A are discretized and a regular QR decomposition is computed
% from this matrix. Note that we do not use Matlab's QR as we cannot control
% the default behaviour when a linearly dependent column is found. The
% resulting quasimatrix Q is re-assembled from the discretized Q.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This algorithm is described in L.N. Trefethen, "Householder 
% triangularization of a quasimatrix", IMA J. Numer. Anal. (30),
% 887-897 (2010).

    % ------------------------------------
    % Define the inner product as a nested function
    function res = innerprod( a , b )
        if hascplx
            res = w * ( conj( a ) .* b );
        else
            res = w * ( a .* b );
        end
    end

    % Check inputs
    if (nargin>2) || ((nargin==2) && (econ~=0))
        error('CHEBFUN:qr:twoargs',...
              'Use qr(A) or qr(A,0) for QR decomposition of quasimatrix.');
    end
    if A(1).trans
        error('CHEBFUN:qr:transpose',...
              'Chebfun QR works only for column quasimatrices.')
    end
    [a,b] = domain(A);
    if any(isinf([a b]))
         error('CHEBFUN:QR:infdomain', ...
               'Chebfun QR does not support unbounded domains.');
    end

    % Get some useful values
    n = size(A,2); R = zeros(n);
    tol = chebfunpref('eps');

    % Check for exponents
    hasexps = false;
    for k=1:numel(A), f = A(k); for j=1:f.nfuns
      hasexps = hasexps || any( f.funs(j).exps ~= 0 );
    end, end

    % Check for non-linear maps
    nonlinmap = false;
    for k=1:numel(A), f = A(k); for j=1:f.nfuns
      nonlinmap = nonlinmap || ~strcmp( f.funs(j).map.name , 'linear' );
    end, end

    % Is anything funky going on in A?
    if ~hasexps && ~nonlinmap % && false

        % Get a hand on some useful values
        hascplx = ~isreal(A);
        kind = chebfunpref('chebkind');

        % Get the set of breakpoints for all funs in A
        ends = [];
        for k=1:n, ends = union( ends , A(k).ends ); end
        ends = ends(:).';
        iends = ends(2:end-1)';
        m = length(ends)-1;

        % Get the sizes of the funs in the columns of A, keeping in mind that we
        % will have to multiply with the columns of E and the norm of A's columns
        sizes = zeros( m , n );
        for k=1:n
            f = A(k); ef = f.ends;
            for j=1:m
                sizes(j,k) = f.funs( find( ef > (ends(j)+ends(j+1))/2 , 1 ) - 1 ).n;
            end
        end
        sizes = 2 * max( max( sizes , n ) , [] , 2 );
        inds = [ 0 ; cumsum(sizes) ];
        
        % Create the chebyshev nodes and quadrature weights
        [ pts , w ] = chebpts( sizes , ends , kind );

        % Make the discrete Analog of A
        dA = zeros( inds(end) , n );
        if m > 1
            for k=1:n
                f = A(k); ef = f.ends;
                for j=1:m
                    ind = find( ef > (ends(j)+ends(j+1))/2 , 1 ) - 1;
                    dA( inds(j)+1:inds(j+1) , k ) = feval( f.funs(ind) , pts( inds(j)+1:inds(j+1) ) );
                end
            end
        else
            for k=1:n
                dA( : , k ) = chebpolyval( [ zeros( sizes(1) - A(k).funs.n , 1 ) ; A(k).funs.coeffs ] );
            end
        end
        
        % Generate a discrete E directly
        [a,b] = domain(A);
        xx = 2*(pts - (a+b)/2)/(b-a);
        dE = ones( inds(end) , n );
        dE(:,2) = xx;
        for k=3:n
            dE(:,k) = ( (2*k-3)*xx.*dE(:,k-1) - (k - 2)*dE(:,k-2) ) / (k - 1);
        end
        for k=1:n
            dE(:,k) = dE(:,k) * sqrt( (2*k-1) / (b-a) );
        end

        % Pre-allocate the matrix V
        V = zeros( sum(sizes) , n );

        % Now actually do the QR-thing, just with the discretized values
        for k=1:n

            % Indices of the previous and following columns
            I = 1:k-1; J = k+1:n;
            scl = max(max(abs(dE(:,k))),max(abs(dA(:,k))));

            % Multiply the kth column of A with the basis in E
            ex = innerprod( dE(:,k) , dA(:,k) );
            aex = abs(ex);

            % Adjust the sign of the kth column in E
            if aex<eps*scl, s=1; else s=-sign(ex/aex); end
            dE(:,k) = dE(:,k) * s;

            % Compute the norm of the kth column of A
            r = sqrt( innerprod( dA(:,k) , dA(:,k) ) );
            R(k,k) = r;

            % Compute the reflection v, make it more orthogonal
            v = r*dE(:,k) - dA(:,k);
            for i=I
                ev = innerprod( dE(:,i) , v );
                v = v - dE(:,i)*ev;
            end

            % Normalize and store v
            nv = sqrt( innerprod( v , v ) );
            if nv < tol*scl;
               v = dE(:,k); 
            else
               v = v / nv; 
            end
            V(:,k) = v;
            

            % Subtract v from the remaining columns of A
            for i=J
                av = innerprod( v , dA(:,i) );
                dA(:,i) = dA(:,i) - 2*v*av;
                rr = innerprod( dE(:,k) , dA(:,i) );
                dA(:,i) = dA(:,i) - dE(:,k)*rr;
                R(k,i) = rr;
            end

        end % loop over columns of A
        
        % Now form a discrete Q from the columns of V.
        dQ = dE;
        for k=n:-1:1
            for i=k:n
                vq = innerprod( V(:,k) , dQ(:,i) );
                dQ(:,i) = dQ(:,i) - 2*V(:,k)*vq;
            end % for i...
        end % for k

        
        % Make a quasimatrix out of the discrete Q
        g = chebfun; % Dummy chebfun
        for k=1:n
            g.nfuns = m;
            g.ends = ends;
            g.scl = norm( dQ( : , k ) , inf );
            g.imps = dQ( [ 1 ; inds(2:end) ] , k )';
            if m > 1
                pcs = {};
                for j=1:m
                    pcs{end+1} = { dQ( inds(j)+1:inds(j+1) , k ) , ends(j:j+1) };
                end
                g.funs = simplify( fun( pcs ) );
            else
                g.funs = simplify( fun( dQ(:,k) , ends ) );
            end
            Q(:,k) = g;
        end


    % otherwise, don't discretize
    else

        % Set up target quasimatrix E with orthonormal columns: 
        E = legpoly(0:n-1,[a,b],'norm');

        % Householder triangularization:
        V = chebfun;                           % cols of V will store Househ. vectors
        for k = 1:n
           I = 1:k-1; J = k+1:n;               % convenient abbreviations
           e = E(k);                         % target for this reflection
           x = A(k);                         % vector to be mapped to s*r*e
           ex = e'*x; aex = abs(ex);
           if aex==0, s=1; else s=-ex/aex; end
           e = s*e; E(k) = e;                % adjust e by sign factor
           r = norm(x); R(k,k) = r;            % diagonal entry r_kk
           v = r*e - x;                        % vector defining reflection
           if k>1                              
              v = v - E(I)*(E(I)'*v);      % improve orthogonality
           end
           nv = norm(v);
           if nv < tol*max(x.scl,e.scl);
               v = e; 
           else
               v = v/nv; 
           end
           V(:,k) = v;                         % store this Householder vector
           if k<n
              A(J) = A(J)-2*v*(v'*A(J)); % apply the reflection to A
              rr = e'*A(J); R(k,J) = rr;     % kth row of R
              A(J) = A(J) - e*rr;          % subtract components in direction e
           end
           A = jacreset(A);
        end
        
        % Form the quasimatrix Q from the Householder vectors:

        Q = E;
        for k = n:-1:1
          v = V(k);
          J = k:n;
          w = v'*Q(J);
          Q(J) = Q(J) - 2*v*w;
        end

    end
    
end
