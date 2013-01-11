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
    
    if isempty(f) || isempty(g), h=chebfun; return, end

    fimps = f.imps(2:end,:);
    gimps = g.imps(2:end,:);
    if any(fimps(:)~=0) || any(gimps(:)~=0)
      error('CHEBFUN:conv:nodeltas','Impulses not implemented for convolution.')
    end

    h = chebfun;

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
    %res = chebfunpref('resampling');
    pref = chebfunpref;
    pref.sampletest = false;
    pref.resampling = false;
    pref.splitting = false;
    pref.blowup = false;
    pref.extrapolate = true;
    
    % Flip g around
    gflip = flipud( g );

    % Construct funs
    for k = 1:length(ends)-1  
        newfun = fun( @(x) integral(x,f,gflip) , ends(k:k+1) , pref , scl );
        scl.v = max(newfun.scl.v, scl.v); newfun.scl = scl;
        funs = [ funs , newfun ];
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

end   % conv()

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
            fn = g.funs( find( g.ends + x(k) > m , 1 ) - 1 );
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
                dg( inds(j)+1:inds(j+1) ) = feval( g.funs( find( g.ends + x(k) > m , 1 ) - 1 ) , pts( inds(j)+1:inds(j+1) ) - x(k) );
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
