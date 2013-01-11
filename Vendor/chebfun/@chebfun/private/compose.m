function h = compose(f,g)
% COMPOSE chebfun composition
%   COMPOSE(F,G) returns the composition of the chebfuns F and G, F(G). The
%   range of G must be in the domain of F.
%
%   Example:
%           f = chebfun(@(x) 1./(1+100*x.^2));
%           g = chebfun(@(x) asin(.99*x)/asin(.99));
%           h = compose(f,g);

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(g,'chebfun') && f(1).trans ~= g(1).trans
    error('CHEBFUN:compose:QMdim','Inconsistent quasimatrix dimensions');
end

if numel(g) == 1
    % Avoid composing with independant variable.
    if isa(g,'chebfun')
        xg = chebfun('x',g.ends,2);
        if norm(g-xg,2) == 0,h = f; return, end
    end
    if isa(f,'chebfun')
        xf = chebfun('x',f.ends,2);
        if norm(f-xf,2) == 0,h = chebfun(g); return, end
    end
    
    for k = 1:numel(f)
        h(k) = composecol(f(k),g);
        % AD information when using compose
        h(k).jacobian = anon('[Jfg nonConstJfg] = diff(f,g,''linop''); [Jgu nonConstJgu] = diff(g,u,''linop''); der = Jfg*Jgu; nonConst = (~Jfg.iszero & ~Jgu.iszero) | (nonConstJgu | nonConstJfg);',{'f' 'g'},{f(k),g},1);
        h(k).ID = newIDnum;
    end
elseif numel(f) == 1
    
    % Avoid composing with independant variable.
    if isa(f,'chebfun')
        x = chebfun('x',f.ends,2);
        if norm(f-x,2) == 0,h = g; return, end
    end
    
    for k = 1:numel(g)
        h(k) = composecol(f,g(k));
        h(k).jacobian = anon('[Jfg nonConstJfg] = diff(f,g,''linop''); [Jgu nonConstJgu] = diff(g,u,''linop''); der = Jfg*Jgu; nonConst = (~Jfg.iszero & ~Jgu.iszero) | (nonConstJgu | nonConstJfg);',{'f' 'g'},{f,g(k)},1);
        h(k).ID = newIDnum;
    end
elseif size(f) == size(g)
    for k = 1:numel(f)
        h(k) = composecol(f(k),g(k));
        h(k).jacobian = anon('[Jfg nonConstJfg] = diff(f,g,''linop''); [Jgu nonConstJgu] = diff(g,u,''linop''); der = Jfg*Jgu; nonConst = (~Jfg.iszero & ~Jgu.iszero) | (nonConstJgu | nonConstJfg);',{'f' 'g'},{f(k),g(k)},1);
        h(k).ID = newIDnum;
    end
else
    error('CHEBFUN:compose:QMdim','Inconsistent quasimatrix dimensions.')
end


function h  = composecol(f,g)
% Composition of two column chebfuns.

gischeb = true;
if isa(g,'function_handle')
    gischeb = false;
    ghandle = g;
    g = chebfun(g, 'splitting', true);
end

% Use vertical orientation
trans = f.trans; f.trans = false; g.trans = false;

% Delta functions ?
if size(f.imps,1) > 1 || size(g.imps,1) >1
    warning('CHEBFUN:compose:imps', 'Composition does not handle delta functions')
end

% g must be a real-valued function
if ~isreal(g)
    %     error('CHEBFUN:compose:complex', 'G must be real valued to construct F(G).')
    %     warning('CHEBFUN:compose:complex', 'G SHOULD be real valued to construct F(G).');
    % Experimental feature allows composition when G has a complex range.
    %   This is only really of any use when F is constructed from a
    %   polynomial otherwise approximation off the real line is awful.
end

tol = 100*chebfunpref('eps');

% Range of g must be in the domain of f.
r = minandmax(g);
if f.ends(1) > r(1) + tol || f.ends(end) < r(2) - tol && isreal(g)
    error('CHEBFUN:compose:domain','F(G): range of G, [%g, %g], must be in the domain of F, [%g, %g].', r(1), r(2), f.ends(1), f.ends(2))
end

% If f has breakpoints, find the corresponding x-points in the domain of g.
bkpts = [];
if f.nfuns >1
    bkf = f.ends(f.ends > r(1) - tol & f.ends < r(2) + tol);
    for k = 1:length(bkf)
        bkpts = [bkpts; roots(g-bkf(k))];
    end
end

ends = union(g.ends, bkpts);

if gischeb
    
    % Construct the chebfun of the composition using horizontal concatenation
    h = chebfun;
    for k = 1:length(ends)-1
        g1 = restrict(g,ends(k:k+1));
        %vals = g1.funs.vals; a = max(vals); b = min(vals);
        %g1.funs.vals = (1-1e-12)*(vals-(a+b)/2)+(a+b)/2;
        h = [h; comp(g1,@(g) feval(f,g))];
    end
    
else
    
    if ~chebfunpref('splitting')
        ends =union(g.ends([1, end]), bkpts);
    end
    
    % Construct the chebfun of the composition using horizontal concatenation
    h = chebfun;
    for k = 1:length(ends)-1
        h = [h; chebfun(@(x) feval(f,ghandle(x)),ends(k:k+1))];
    end
    
end
% Fix orientation
h.trans = trans;

% Fix imps values
h.imps(1,:) = feval(f, feval(g,h.ends));
