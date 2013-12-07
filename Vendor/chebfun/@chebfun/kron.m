function h = kron(f,g,varargin)
%KRON   Kronecker/outer product of two chebfuns.
%
% H = KRON(F,G) where F and G are chebfun/quasimatrices constructs a
% chebfun2.  If size(F)=[Inf,K] and size(G)=[K,Inf] then H is a rank K
% chebfun2 such that
%
%  H(x,y) = F(y,1)*G(x,1) + ... + F(y,K)*G(x,K).
%
% If size(F)=[K,Inf] and size(G)=[Inf,K] then H is a chebfun2 such that
%
%  H(x,y) = G(y,1)*F(x,1) + ... + G(y,K)*F(x,K).
%
% This is function analogue of the Matlab command KRON.
%
% H = KRON(F,G,'op') or H = KRON(F,G,'operator') if F is Inf-by-m and 
% G is m-by-Inf, results in a rank-m linop A such that A*U = F*(G*U) for 
% any chebfun U.  
%
% See also KRON.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( ~isa(f,'chebfun') || ~isa(g,'chebfun') )
    error('CHEBFUN:KRON:INPUTS','Both inputs should be chebfuns');
end


if ( isempty(f) || isempty(g) )
    h = chebfun2;  % return empty chebfun2
    return;
end

% get domains of chebfuns
fint = f.ends;
gint = g.ends;

if ( length(fint) > 2 || length(gint) > 2 )
    error('CHEBFUN:KRON:BREAKPTS','The two chebfuns must be smooth and contain no break points.');
end


if ( nargin <= 2 )
    
    % check if we have the right sizes:
    [mf,nf]=size(f);
    [mg,ng]=size(g);
    
    if ( ( mf ~= ng ) || ( nf ~=mg ) )
        error('CHEBFUN:KRON:SIZES','Inconsistent sizes for the continuous analogue of the Kronecker product.');
    end
    
    % call chebfun2 constructor
    if isinf(mf)
        rect = [gint fint];
        h = chebfun2(0,rect);
        for kk = 1:nf
            h = h + chebfun2(@(x,y) feval(f(kk),y).*feval(g(kk),x), rect);
        end
    elseif isinf(nf)
        rect = [fint gint];
        h = chebfun2(0,rect);
        for kk = 1:mf
            h = h + chebfun2(@(x,y) feval(g(kk),y).*feval(f(kk),x), rect);
        end
    else
        % We can probably never reach here, but display an error if we do.
        error('CHEBFUN:KRON:INFSIZES','Kronecker product only works for chebfuns and quasimatrices.');
    end
    
elseif ( nargin == 3 )
    % Historically, this used to be called by f*g'.  Now it is here because
    % we wanted to use f*g' to generate a low rank chebfun2 object. 
    if ( strcmpi(varargin{1}, 'op') || strcmpi(varargin{1}, 'operator') )
        splitstate = chebfunpref('splitting');
        splitting off
        sampstate = chebfunpref('resampling');
        resampling on
        h = 0;
        d = domain(f);
        if ~(d==domain(g))
            error('CHEBFUN:mtimes:outerdomain',...
                'Domains must be identical for outer products.')
        end
        for i = 1:size(f,2)
            fi = f(i);
            gi = g(i);
            op = @(u) fi * (gi*u);  % operational form
            
            % Matrix form available only for unsplit functions.
            if fi.nfuns==1 && gi.nfuns==1
                x = @(n) d(1) + (1+sin(pi*(2*(1:n)'-n-1)/(2*n-2)))/2*length(d);
                C = cumsum(d);
                w = C(end,:);  % Clenshaw-Curtis weights, any n
                mat = @(n) matfun(n,w,x,fi,gi);
            else
                mat = [];
            end
            h = h + linop(mat,op,d);
        end
        chebfunpref('splitting',splitstate)
        chebfunpref('resampling',sampstate)
    else
        error('CHEBFUN:KRON:OPTS','Unrecognized optional parameter.');
    end
else
    error('CHEBFUN:KRON:NARGIN','Too many input arguments.');
end

end


% ------------------------------------  for linop outer product. 
function m = matfun(n,w,x,f,g)
    if iscell(n), n = n{1}; end
    m = feval(f,x(n)) * (w(n) .* feval(g,x(n)).');
end
