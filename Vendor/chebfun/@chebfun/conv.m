function Fout = conv(F1,F2)
% CONV   Convolution of chebfuns.
% 
% H = CONV(F,G) produces the convolution of chebfuns F and G:
% 
%                   - 
%                  /
%         H(x) =   |    F(t) G(x-t) dt,
%                  /
%                 -
% 
% defined for x in [a+c,b+d], where domain(F) is [a,b] and domain(G) is
% [c,d]. The integral is taken over all t for which the integrand is
% defined: max(a,x-d) <= t <= min(b,x-c).
%
% The breakpoints of H are all pairwise sums of the breakpoints of F
% and G.
%
% EXAMPLE
%
%   f=chebfun(1/2); g=f;
%   subplot(2,2,1), plot(f)
%   for j=2:4, g=conv(f,g); subplot(2,2,j), plot(g), end
%   figure, for j=1:4, subplot(2,2,j), plot(g), g=diff(g); end

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    % Deal with quasi-matrices
    if size(F1) ~= size(F2)
        error('CHEBFUN:conv:quasi','Quasi-matrix dimensions must agree')
    end
    Fout = F1;
    for k = 1:numel(F1)
        Fout(k) = convcol(F1(k),F2(k));
    end

end %conv()


% Deal with single column chebfun
% ---------------------------------
function h = convcol(f,g)

    % Note: f and g may be defined on different domains!
    h = chebfun;
    if isempty(f) || isempty(g), return, end

    % if there are delta functions in f or g
    fimps = []; gimps = [];
    if( size(f.imps,1) >= 2 )
        fimps = f.imps(2:end,:);  % store the deltas
        f.imps = f.imps(1,:);     % remove deltas from f
    end
    if( size(g.imps,1) >= 2 )
        gimps = g.imps(2:end,:);  % store the deltas
        g.imps = g.imps(1,:);     % remove deltas from g
    end

    % Find all breakpoints in the convolution.
    [A,B] = meshgrid(f.ends,g.ends);
    ends = unique( A(:) + B(:) ).';

    % Coalesce breaks that are close due to roundoff.
    ends( diff(ends) < 10*eps*max(abs(ends([1,end]))) ) = [];
    ends(isnan(ends)) = [];

    a = f.ends(1); b = f.ends(end); c = g.ends(1); d = g.ends(end);
    funs = [];

    scl.h = max(hscale(f),hscale(g));
    scl.v = 2*max(g.scl,f.scl);

    % Avoid resampling for speed up!
    pref = chebfunpref;
    pref.sampletest = false;
    pref.resampling = false;
    pref.splitting = false;
    pref.blowup = false;
    pref.extrapolate = false;
    
    if ( ~any(isinf(domain(g))) )
        
        % Flip g around
        gflip = flipud( g );
        gflip = newdomain(gflip,-domain(g));
    
        % Construct funs
        for k = 1:length(ends)-1  

            % note that deg(H(x)) = deg(gflip)+deg(f)+1 where deg(gflip) =
            % length(gflip)-1 and deg(f) = length(f)-1. Hence, length(H(x)) =
            % deg(gflip)+deg(f)+2 = length(gflip)+length(f). The adaptive 
            % construction process with fun of increasing length is avoided.
            pref.n = length(gflip)+length(f);
            newfun = fun( @(x) integral(x,f,gflip) , ends(k:k+1) , pref);
            scl.v = max(newfun.scl.v, scl.v); newfun.scl = scl;
            funs = [ funs , newfun ];
        end
    else
        % Unbounded domains must be treated differently. This may be much slower.
        
        % Construct funs
        for k = 1:length(ends)-1 
            newfun = fun(@(x) integral_old(x,a,b,c,d,f,g,pref,scl), ends(k:k+1), pref, scl);
            scl.v = max(newfun.scl.v, scl.v); newfun.scl = scl;
            funs = [funs simplify(newfun)];
        end

    end

    % Construct chebfun
    h.scl = scl.v;
    h.funs = simplify( funs );
    h.ends = ends;
    h.nfuns = length(ends)-1;

    % function values in imps 
    imps = 0*h.ends;
    for k = 1:h.nfuns
        imps(k) = get(funs(k),'lval');
    end
    imps(k+1) =  get(funs(k),'rval');
    h.imps = imps; 
    h = update_vscl(h);
    h.trans = f.trans;
    
    %% 
    % CONVOLUTION OF DELTA FUNCTIONS
    % convolution if f or g has dirac delta functions.
    % Note: delta functions of f and g are already cleaned
    % up and are stored in the variables fimps and gimps
    
    % if f has delta functions
    isfimps = any(any(abs(fimps)>100*eps));
    if(isfimps)
        [m n] = size(fimps);
        % loop through the imps matrix
        for i = 1:m
            for j = 1:n
                if(abs(fimps(i,j)) > 100*eps)
                    % take appropriate derivative and shift the function
                    gshift = newdomain(diff(g,i-1),[g.ends(1)+f.ends(j) g.ends(end)+f.ends(j)]);
                    % pad with zero chebfuns on either side
                    l = chebfun( 0, [h.ends(1) gshift.ends(1) ] );
                    r = chebfun( 0, [gshift.ends(end) h.ends(end) ] );
                    gshift = chebfun( [ l; gshift; r ], [ h.ends(1) gshift.ends(1) gshift.ends(end) h.ends(end) ] );
                    % scale by the impulse value and add
                    h = h + fimps(i,j)*gshift;
                end                     
            end
        end
    end
    
    % if g has delta funtions, do the same as above 
    isgimps = any(any(abs(gimps)>100*eps));
    if(isgimps)
        [m n] = size(gimps);
        for i = 1:m
           for j = 1:n
               if(abs(gimps(i,j)) > 100*eps)
                   fshift = newdomain(diff(f,i-1),[f.ends(1)+g.ends(j) f.ends(end)+g.ends(j)]);
                   l = chebfun( 0, [h.ends(1) fshift.ends(1) ] );
                   r = chebfun( 0, [fshift.ends(end) h.ends(end) ] );
                   fshift = chebfun( [ l; fshift; r ], [ h.ends(1) fshift.ends(1) fshift.ends(end) h.ends(end) ] );
                   h = h + gimps(i,j)*fshift;
               end
           end
        end
    end
         
    % if both f and g have delta functions
    if(isfimps && isgimps)
        [m n] = size(fimps);
        [p q] = size(gimps);
        himps = zeros(m+p-1,length(h.ends));
        for i=1:m
            for j=1:n
                if(abs(fimps(i,j))>100*eps)
                    % find the locations of shifted ends in h.ends
                    [xx yy] = meshgrid(h.ends,f.ends(j)+g.ends);
                    idx = find(sum(~(abs(xx-yy)>100*eps)));
                    % place the scaled and shifted impulses in himps
                    himps(i:i+p-1,idx) = ...
                    himps(i:i+p-1,idx) + fimps(i,j)*gimps;
                end
            end
        end
        % append delta functions to the imps of h
        h.imps = [ h.imps; himps ];    
    end
    %%
    
end   % conv()

%%
function out = integral( x , f , g )
% Assume that g has been flipped!

    % Get the chebpts kind
    kind = chebfunpref('chebkind');

    % init the output vector
    out = zeros(size(x));
    
    % Loop over the input values
    for k=1:length(x)
    
        % Do f and g overlap for this x?
        if ( f.ends(end) <= g.ends(1) + x(k) ) || ( f.ends(1) >= g.ends(end) + x(k) )
            continue;
        end
    
        % get the common ends in f and the shifted g
        ends = union( f.ends , g.ends + x(k) );
        
        % Trim the ends so that we only have the overlapping bit
        l = 1; r = length(ends);
        while ends(l) < f.ends(1) || ends(l) < g.ends(1) + x(k),  l = l + 1; end
        while ends(r) > f.ends(end) || ends(r) > g.ends(end) + x(k),  r = r - 1; end
        ends = ends( l:r );
        nfuns = length(ends) - 1;
        
        % Get the sizes in each interval (look for non-linear maps and/or exps 
        % while we're at it)
        hasexps = false; nonlinmaps = false;
        sizes = zeros( nfuns , 1 );
        
        for j=1:nfuns
            m = (ends(j)+ends(j+1))/2;
            fn = f.funs( find( f.ends > m , 1 ) - 1 );
            hasexps = hasexps || any( fn.exps ~= 0 );
            nonlinmaps = nonlinmaps || ~strcmp( fn.map.name , 'linear' );
            sizes(j) = fn.n;
            idx = find( g.ends + x(k) > m , 1 ) - 1;
            if ( isempty(idx) ) % Sometimes we miss the final interval.
                idx = numel(g.funs);
            end
            fn = g.funs(idx);
            hasexps = hasexps || any( fn.exps ~= 0 );
            nonlinmaps = nonlinmaps || ~strcmp( fn.map.name , 'linear' );
            sizes(j) = sizes(j) + fn.n - 1;
        end
        inds = [ 0 ; cumsum(sizes) ];
        
        % No exponents or non-linear maps in the overlap?
        if ~hasexps && ~nonlinmaps
        
            % Get the nodes and weights on these intervals
            [ pts , w ] = chebpts( sizes , ends , kind );

            % Discretize f and g
            df = zeros( inds(end) , 1 ); dg = zeros( inds(end) , 1 );
            for j=1:nfuns
                m = (ends(j)+ends(j+1))/2;
                df( inds(j)+1:inds(j+1) ) = feval( f.funs( find( f.ends > m , 1 ) - 1 ) , pts( inds(j)+1:inds(j+1) ) );
                idx = find( g.ends + x(k) > m , 1 ) - 1;
                if ( isempty(idx) ) % Sometimes we miss the final interval.
                    idx = numel(g.funs);
                end
                dg( inds(j)+1:inds(j+1) ) = feval( g.funs( idx ) , pts( inds(j)+1:inds(j+1) ) - x(k) );
            end

            % Compute the integral
            out(k) = w * ( df .* dg );
            
        % Otherwise, do it conventionally
        else
        
            % Integrate over the intervals using chebfun
            for j=1:nfuns
                u = fun( @(t) feval(f,t).*feval(g,t-x(k)) , ends(j:j+1) );
                out(k) = out(k) + sum(u);
            end
                
        end

    end % loop over input values

end % integral

function out = integral_old(x,a,b,c,d,f,g,pref,scl)
    out = 0.*x;
    for k = 1:length(x)
        A = max(a,x(k)-d); B = min(b,x(k)-c);
        if A < B      
            ends = union(x(k)-g.ends,f.ends);
            ee = [A ends(A<ends & ends< B)  B];
            for j = 1:length(ee)-1
                F = @(t) feval(f,t).*feval(g,x(k)-t);
                tol = max(100*eps('double'), scl.h*scl.v*eps);
                out(k) = out(k) + quadgk(F, ee(j), ee(j+1), 'AbsTol', tol , 'RelTol', tol); 
            end
        end
    end
end % integral_old()