function [lines marks jumps jval misc] = plotdata(f,g,h,numpts,interval)
% PLOTDATA returns data (double) for plotting chebfuns.
% This function is used in PLOT, PLOT3, WATERFALL, ...
%
% INPUT: F,G,H are quasimatrices (F and H are optional). NUMPTS is the
% number of data points to be generated.
%
% OUTPUT: LINES cell array with line data. MARKS cell array for markers at
% chebyshev data. JUMPS cell array to generate jump lines. JVAL function
% value at jump points.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

misc = []; infy = false;
if nargin < 5, interval = []; end

unbndd_def = 10; % Default interval for functions on unbounded domains.

% Check domains: f,g,h must have the same domain
if ~isempty(f)
    if any(f(1).ends([1,end]) ~= g(1).ends([1,end]))
        error('CHEBFUN:plot:domain','Inconsistent domains');
    end
    if ~isempty(h)
        if any(f(1).ends([1,end]) ~= h(1).ends([1,end]))
            error('CHEBFUN:plot:domain2','Inconsistent domains');
        end
    end
end

marks = {}; jumps = {}; jval = {};
if isempty(f) && isempty(g)
    lines = {};
    return
end

% Set the plotting interval
dom = g(1).ends([1 end]);% by default use the whole domain
if ~isempty(interval)
    % user defined
    if isa(interval,'domain'); interval = interval.ends; end
    if interval(1) < dom(1), interval(1) = dom(1); end
    if interval(2) > dom(2), interval(2) = dom(2); end
    dom = interval(1:2);
elseif any(isinf(g(1).ends([1 end]))) 
    % defaults for unbounded domains
    if all(isinf(g(1).ends([1 end])))
        dom = [-unbndd_def,unbndd_def];
    elseif isinf(g(1).ends(end))
        dom = [g(1).ends(1),g(1).ends(1)+2*unbndd_def];
    elseif isinf(g(1).ends(1))
        dom = [-2*unbndd_def+g(1).ends(end),g(1).ends(end)];
    end     
end
% Don't exclude anything
if isempty(interval), 
    if isempty(f), interval = dom;
    else interval = [-inf inf]; end
end

if isempty(f)
    % one real chebfun (or quasimatrix) input
    g = set(g,'funreturn',0);
    
    % is g real?
    greal = isreal(g);
    
    % Make g a column chebfun
    if g(1).trans
        g = g.';
    end
    
    % initialise y limits (auto adjusted if there are exps)
    top = -inf; bot = inf;
    
    % If all chebfuns have one piece and the same map, we can simplify
    % things and plot at an oversampled chebyshev grid, which is much
    % faster to evaluate than equally spaced points
    issimple = all([g.nfuns]==1);
    if issimple
        map = g(1).funs(1).map;
        issimple = ~any(g(1).funs(1).exps);
        for k = 2:numel(g)
            issimple = strcmp(g(k).funs(1).map.name,map.name) && ~any(g(k).funs(1).exps);
            if ~issimple, break, end
        end
    end
    
    a = dom(1); b = dom(2);
    if issimple
        % oversampled (mapped) chebyshev grid
        numpts = max(numpts,pi/2*length(g));
        n = power(2,ceil(log2(numpts)));
        fl = chebpts(n);
        fl = map.for(fl);
    else
        % equispaced points over domain
        fl = linspace(a,b,numpts).';
    end
    
    % find all the ends and get rid of high order imps
    ends = [];
    for k = 1:numel(g)
        ends = [ends g(k).ends];
        g(k).imps = g(k).imps(1,:);
    end
    ends = unique(ends);         
    ends = ends(2:end-1);
    ends(ends<a | ends>b) = [];

    % evaluation points
    fl = [reshape(repmat(ends,3,1),3*length(ends),1) ; setdiff(fl,ends.')];
    mask = [];
    if greal
        % remove values outside interval
        mask = (fl < a) | (fl > b);
        fl(mask) = [];
    end
    % sort
    [fl indx] = sort(fl);    
    [ignored indx2] = sort(indx);

    % line values of g
    if issimple
        gl = zeros(n,numel(g));
        for k = 1:numel(g)
            gl(:,k) = get(prolong(g(k).funs(1),n),'vals');
        end
        gl(mask,:) = [];
    else
        gl = feval(g,fl);
    end
    
    if fl(1) == a, 
        for k = 1:size(gl,2)
            gl(1,k) = get(g(k).funs(1),'lval'); 
        end
    end
    if fl(end) == b, 
        for k = 1:size(gl,2)
            gl(end,k) = get(g(k).funs(end),'rval'); 
        end
    end
    
    % Who put this here?
    dg = g(1).ends([1 end]);
    if a~=dg(1), gl(1,:) = feval(g,a);   end
    if b~=dg(end), gl(end,:) = feval(g,b);   end
    % deal with marks breakpoints
    for k = 1:numel(g)
        gk = g(k);
        endsk = get(gk,'ends');

        % With markfuns we need to adjust the vals when getting marks
        fmk = []; gmk = []; expsk = [];
        for j = 1:gk.nfuns
            fmkj = get(gk.funs(j),'points');
            gmkj = get(gk.funs(j),'vals');
            expskj = get(gk.funs(j),'exps');
            
            mask = (fmkj < a) | (fmkj > b);
            fmkj(mask) = [];
            gmkj(mask) = [];

            if all(isfinite(endsk(j:j+1)))
                rescl = (2/diff(gk.funs(j).map.par(1:2)))^sum(expskj);
                gmkj = rescl*gmkj.*((fmkj-endsk(j)).^expskj(1).*(endsk(j+1)-fmkj).^expskj(2)); % adjust using exps
            else
                x = gk.funs(j).map.inv(fmkj);
                s = gk.funs(j).map.par(3);
                if all(isinf(endsk)), rescl = .5/(5*s);
                else                 rescl = .5/(15*s);               end
                rescl = rescl.^sum(expskj);
                gmkj = rescl*gmkj.*((x+1).^expskj(1).*(1-x).^expskj(2)); 
            end
            
            expsk = [expsk ; expskj(1)];

            fmk = [fmk ; fmkj]; % store global x-marks
            gmk = [gmk ; gmkj]; % store global y-marks
        end 
        expsk = [expsk ; expskj(2)];
        
        exps = reshape(get(gk,'exps')',2*gk.nfuns,1);
        expsk = [exps(1) ; zeros(gk.nfuns,1)];
        for j = 1:gk.nfuns-1
            expsk(j+1) = min(exps(2*j),exps(2*j+1));
        end
        expsk(gk.nfuns+1) = exps(end);
        
        % Auto adjust y limits based upon standard deviation
        if any(any(get(gk,'exps')<0))
            infy = true;
            val = 0.1; mintrim = 5;
            
            % Find the break points for the current quasimatrix
            breaksk = zeros(length(endsk),1);
            for l = 1:length(endsk)
                if endsk(l) < a
                    breaksk(l) = 1;
                elseif endsk(l) > b
                    breaksk(l) = length(fl);
                elseif isinf(endsk(l))
                    breaksk(l) = length(fl)*(1+sign(endsk(l)))/2;
                else
                    breaksk(l) = find(fl==endsk(l),1);
                end
            end
            dbk = diff(breaksk);
            
            nnl = max(round(-val*dbk.*expsk(1:end-1)),mintrim);
            nnr = max(round(-val*dbk.*expsk(2:end)),mintrim);
            mask = [];
            for j = 1:length(breaksk)-1
                mask = [mask breaksk(j)+nnl(j):breaksk(j+1)-nnr(j)];
            end
            if ~isempty(mask)
                mask([1 end]) = [];
            end
            masked = gl(mask,k);
%             % Remove things that look too big.
%             diffmasked = diff(abs(masked));
%             toobig = find(abs(diffmasked) > 1e13);
%             masked(toobig+.5*(1+sign(diffmasked(toobig)))) = [];
            sd = std(masked);
            bot = min(bot,min(masked)-sd);
            top = max(top,max(masked)+sd);
        end

        % Jump lines (fjk,gjk) and jump values (jvalf,jvalg)
        nends = length(endsk(2:end-1));
        if nends > 0
            fjk = reshape(repmat(endsk(2:end-1),3,1),3*nends,1); 
        else
            fjk = NaN(3,1);
        end
        [gjk jvalg isjg] = jumpvals(g(k),endsk);
        gjk2 = gjk;
        jvalf = endsk.';
        
        % remove jval data outside of 'interval'
        if greal
            mask = jvalf<a | jvalf>b;
            jvalf(mask) = NaN; jvalg(mask) = NaN;
        end

        % Remove continuous breakpoints from jumps:
        for j = 1:length(endsk)
            if ~isjg(j)
                jvalg(j) = NaN;
                jvalf(j) = NaN;
            end
        end
        if greal
            jval = [jval jvalf jvalg];
        else
            jval = [jval NaN NaN];
            % do not plot jumps
            fjk = NaN;
            gjk = NaN;
            
            % x = real data, y = imag data
            fmk = real(gmk);
            gmk = imag(gmk);
            
%             mask = (fmk < interval(1)) | (fmk > interval(2));
%             fmk(mask) = []; gmk(mask) = [];
        end
        
        % breakpoints
        for j = 2:length(endsk)
            if endsk(j) >= a && endsk(j) <= b
                TL = ismember(endsk(j),ends);
%                 [TL loc] = ismember(endsk(j),ends);
                if TL %&& ~any(isinf(gl(indx2(3*(loc-1)+(1:3)+1),k)))
                    % values on either side of jump
    %                 jmpvls = [ gk.funs(j-1).vals(end); NaN ; gk.funs(j).vals(1) ];
    %                 jmpvls = [  gk.funs(j-1).vals(end)*diff(endsk(j-1:j)).^sum(gk.funs(j-1).exps)
    %                             NaN
    %                             gk.funs(j).vals(1)*diff(endsk(j:j+1)).^sum(gk.funs(j).exps)];
    %                 [jmpvls ignored ignored] = jumpvals(g(k),endsk(j-1:j+1));
                    jmpvls = gjk2(3*(j-2)+[1 3 2]);
    %                 gl(indx2(3*(loc-1)+[1 3 2]+1),k) = jmpvls;
                    gl(fl==endsk(j),k) = jmpvls;
                end
            end
        end
        
        if greal
            % remove values outside interval
            mask = (fjk < a) | (fjk > b);
            fjk(mask) = []; gjk(mask) = [];
        end
        
        % store jumps and marks
        jumps = [jumps, fjk, gjk];
        % With 'interval', there might not actually be any marks.
        if numel(fmk) == 0, fmk = NaN; gmk = NaN; end
        marks = [marks, fmk, gmk];
    end

    % store lines
    if ~greal
        mask = (fl < a) | (fl > b);
            
        fl = real(gl);
        gl = imag(gl);
        
        fl(mask) = [];
        gl(mask) = [];
        
%         % remove data outside of real 'interval'
%         mask = (fl < interval(1)) | (fl > interval(2));
%         fl(mask) = []; gl(mask) = [];
    end
    
    lines = {fl, gl};
    if ~isfinite(bot), bot = min(gl); end
    if ~isfinite(top), top = max(gl); end
    misc = [infy bot top];
    
elseif isempty(h) % Two quasimatrices case
    f = set(f,'funreturn',0);
    g = set(g,'funreturn',0);
    
    % f and g are both chebfuns/quasimatrices
    nf = numel(f);
    ng = numel(g);
    
    % Check size
    if  nf~=ng && nf~=1 && ng~=1
        error('CHEBFUN:plot:quasisize','Inconsistent quasimatrix sizes');
    end
    
    % Deal with row quasimatrices
    if f(1).trans ~= g(1).trans
        error('CHEBFUN:plot:quasisize2','Inconsistent quasimatrix sizes');
    end
    if f(1).trans
        f = f.'; g = g.';
    end
    
    if nf == 1
        couples = [ones(1,ng) ; 1:ng].';
    elseif ng == 1
        couples = [1:nf ; ones(1,nf)].';
    else
        couples = [1:nf ; 1:ng].';
    end
    
    % lines 
    h = [f g];
    lines = plotdata([],h,[],numpts,interval);
    fl = lines{2}(:,1:nf);
    gl = lines{2}(:,(nf+1):end);
    lines = {fl, gl};
    
    % Jump lines:
    jumps = {}; jval = {};
    for k = 1:max(nf,ng)
        kf = couples(k,1); kg = couples(k,2);
        ends = unique([f(kf).ends,g(kg).ends]);
        [jumps{2*k-1} jval{2*k-1} isjf] = jumpvals(f(kf),ends);
        [jumps{2*k} jval{2*k} isjg] = jumpvals(g(kg),ends); 
        % Remove continuous breakpoints from jumps:
        for j = 1:length(ends)
            if ~isjf(j) && ~isjg(j)
                jval{2*k-1}(j) = NaN;
                jval{2*k}(j) = NaN;
            end
        end
    end
       
    % marks
    marks = {};
    for k = 1:max(nf,ng)
        if nf == 1
            [fk,gk] = overlap(f(1),g(k));
        elseif ng == 1
            [fk,gk] = overlap(f(k),g(1));
        else
            [fk,gk] = overlap(f(k),g(k));
        end
        fm = []; gm = [];
        for j = 1:fk.nfuns
            if fk.funs(j).n > gk.funs(j).n
                xgrid = chebpts(fk.funs(j).n,gk.funs(j).map.par(1:2));
%                 fkf = feval(fk.funs(j),xgrid);
                fkf = fk.funs(j).vals;
                gkf = feval(gk.funs(j),xgrid);
                fm = [fm; fkf];
                gm = [gm; gkf];
            else
                xgrid = chebpts(gk.funs(j).n,fk.funs(j).map.par(1:2));
                fkf = feval(fk.funs(j),xgrid);
%                 gkf = feval(gk.funs(j),xgrid);
                gkf = gk.funs(j).vals;
                fm = [fm; fkf];
                gm = [gm; gkf];
            end
        end
        mask = fm < interval(1) | fm > interval(2);
        fm(mask) = []; gm(mask) = [];
        marks{2*k-1} = fm;
        marks{2*k} = gm;
    end
    
else % Case of 3 quasimatrices (used in plot3)
    f = set(f,'funreturn',0);
    g = set(g,'funreturn',0);
    h = set(h,'funreturn',0);
    
    nf = numel(f); ng = numel(g); nh = numel(h);
    if  nf~=ng && nf~=1 && ng~=1 && nh~=1
        error('CHEBFUN:plot:quasisize3','Inconsistent quasimatrix sizes');
    end
        
    % Deal with row quasimatrices
    if  f(1).trans ~= g(1).trans || f(1).trans ~= h(1).trans
        error('CHEBFUN:plot:quasisize4','Inconsistent quasimatrix sizes');
    end
    if f(1).trans
        f = f.'; g = g.'; h = h.';
    end
    
    % lines
    lines = plotdata([],[f g h], [], numpts);
    fl = lines{2}(:,1:nf);
    gl = lines{2}(:,(nf+1):(nf+ng));
    hl = lines{2}(:,(nf+ng+1):end);
    lines = {fl, gl, hl};
    
    n = max([nf,ng,nh]);
    if nf == 1, f = repmat(f,1,n); end
    if ng == 1, g = repmat(g,1,n); end
    if nh == 1, h = repmat(h,1,n); end
    
    % marks
    marks = {};
    for k = 1:n
        [fk,gk] = overlap(f(k),g(k));
        [fk,hk] = overlap(fk, h(k));
        [gk,fk] = overlap(gk, fk);
        fm = []; gm = []; hm = [];
        for j = 1:fk.nfuns
            maxn = max([fk.funs(j).n, gk.funs(j).n, hk.funs(j).n]);
            if fk.funs(j).n == maxn
                fm = [fm; fk.funs(j).vals];
                gkf = prolong(gk.funs(j), fk.funs(j).n);
                gm = [gm; gkf.vals];
                hkf = prolong(hk.funs(j), fk.funs(j).n);
                hm = [hm; hkf.vals];
            elseif gk.funs(j).n == maxn
                gm = [gm; gk.funs(j).vals];
                fkf = prolong(fk.funs(j), gk.funs(j).n);
                fm = [fm; fkf.vals];
                hkf = prolong(hk.funs(j), gk.funs(j).n);
                hm = [hm; hkf.vals];
            else
                hm = [hm; hk.funs(j).vals];
                fkf = prolong(fk.funs(j), hk.funs(j).n);
                fm = [fm; fkf.vals];
                gkf = prolong(gk.funs(j), hk.funs(j).n);
                gm = [gm; gkf.vals];
            end
        end
        marks{3*k-2} = fm;
        marks{3*k-1} = gm;
        marks{3*k} = hm;
    end
    
    % Jump lines and values:
    jumps = {}; jval = {};
    for k = 1:n
        ends = unique([f(k).ends,g(k).ends,h(k).ends]);
        [jumps{3*k-2} jval{3*k-2} isjf] = jumpvals(f(k),ends);
        [jumps{3*k-1} jval{3*k-1} isjg] = jumpvals(g(k),ends); 
        [jumps{3*k} jval{3*k} isjh] = jumpvals(h(k),ends); 
        % Remove continuous breakpoints from jumps:
        for j = 1:length(ends)
            if ~isjf(j) && ~isjg(j) && ~isjh(j)
                jval{3*k-2}(j) = NaN;
                jval{3*k-1}(j) = NaN;
                jval{3*k}(j) = NaN;
            end
        end
    end
    
end



function [fjump jval isjump] = jumpvals(f,ends)
% JUMPVALS returns the vaules of F at jumps (JVAL) and the left and right 
% limits (FJUMP) for plotting jump lines.
% ISJUMP is true if the difference of multiple values at a jump location is
% larger than a tolerace. 
% ENDS is the vector with possible jump locations.

if length(ends) == 2
    fjump = [NaN; NaN; NaN];
else
    fjump = zeros(3*(length(ends)-2),1);
end

hs = max(abs(f.ends([1 end])));
jval = zeros(length(ends),1);
isjump = jval;

tol = 1e-4*f.scl;

jval(1) = f.imps(1,1);
if abs(jval(1)-get(f.funs(1),'lval')) < tol && f.funs(1).exps(1) >= 0
    isjump(1) = false;
else
    isjump(1) = true;
end

ffuns = f.funs;

for j = 2:length(ends)-1
    [MN loc] = min(abs(f.ends-ends(j)));
    if MN < 1e4*eps*hs
        lval = get(ffuns(loc-1),'rval');%*(ends(loc)-ends(loc-1)).^sum(f.funs(loc-1).exps);
        expl = ffuns(loc-1).exps(2);
        if expl < 0, 
            lval = sign(lval)/eps; % 1/eps should be inf or realmax, but this doesn't work?
        elseif expl > 0, 
            lval = 0;   % This is a hack?
        end
        rval = get(ffuns(loc),'lval');%*(ends(loc+1)-ends(loc)).^sum(f.funs(loc).exps);
        expr = ffuns(loc).exps(1);
        if expr < 0, 
            rval = sign(rval)/eps; % 1/eps should be inf or realmax, but this doesn't work?
        elseif expr > 0
            rval = 0;  % This is a hack?  
        end    

        fjump(3*j-(5:-1:3)) = [lval; rval; NaN];
        jval(j) = f.imps(1,loc);
        if abs(lval-rval) < tol && abs(jval(j)-lval) < tol
            isjump(j) = false;
        else
            isjump(j) = true;
        end
    else
        fval = feval(f,ends(j));
        fjump(3*j-(5:-1:3)) = [fval; fval; NaN];
        jval(j) = fval;
        isjump(j) = false;
    end
end

jval(end) = f.imps(1,end);
if abs(jval(end)-ffuns(end).vals(end)) < tol
    isjump(end) = false;
else
    isjump(end) = true;
end
