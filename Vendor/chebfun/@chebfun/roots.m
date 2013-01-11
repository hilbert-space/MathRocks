function rts = roots(f,varargin)
% ROOTS	  Roots of a chebfun.
%
% ROOTS(F) returns the roots of F in the interval where it is defined.
%
% ROOTS(F,'norecursion') deactivates the recursion procedure used to
% compute roots (see the Guide 3: Rootfinding and minima and maxima for
% more information of this recursion procedure).
%
% ROOTS(F,'all') returns the roots of all the polynomials representing the
% smooth pieces of F. Note that by default this disables recursion, and so
% is equivalent to ROOTS(F,'all','norecursion').
%
% ROOTS(F,'complex') returns the roots of all the polynomials representing
% the smooth pieces of F that are inside a chebfun ellipse. This capability
% may remove some spurious roots that can appear if using ROOTS(F,'all').
% ROOTS(F,'complex') is equivalent to ROOTS(F,'complex','recursion').
%
% ROOTS(F,'all','recursion') and ROOTS(F,'complex','norecursion') can be
% used to activates and deactivate the recursion procedure respectively, to
% compute the roots as explained in the 'all' and 'complex' modes.
%
% ROOTS(F,'nopolish') deactivates the 'polishing' procedure of applying a
% Newton step after solving the colleage matrix eigenvalue problem to
% obtain the roots. Since the Chebyshev coefficients of the function have
% already been computed, this comes at very little cost.
%
% ROOTS(chebfun(0,[A,B])) will return by default a zero at the midpoint of 
% the interval [A B], i.e., (A+B)/2. ROOTS(chebfun(0,[A,B]),'nozerofun') 
% will prevent this.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

tol = 1e-14;

if numel(f)>1
    error('CHEBFUN:roots:quasi','roots does not work with chebfun quasi-matrices')
end

f = set(f,'funreturn',0);

% Default preferences
rootspref = struct('all', 0, 'recurse', 1, 'prune', 0, 'polish', chebfunpref('polishroots') , 'old' , false );
zerofun = 1;
recursehasbeenset = 0;
for k = 1:nargin-1
    argin = varargin{k};
    switch argin
        case 'all',
            rootspref.all = 1;
            rootspref.prune = 0;
            if ~recursehasbeenset, rootspref.recurse = 0; end
        case 'complex'
            rootspref.prune = 1;
            rootspref.all = 1;
        case 'polish'
            rootspref.polish = 1;
        case 'nopolish'
            rootspref.polish = 0;
        case 'zerofun'
            zerofun = 1;  
        case 'nozerofun'
            zerofun = 0;              
        case 'old'
            rootspref.old = true;              
        otherwise
            if strncmpi(argin,'rec',3),       % recursion
                rootspref.recurse = 1;
                recursehasbeenset = 1;
            elseif strncmpi(argin,'norec',5), % no recursion
                rootspref.recurse = 0;
            else
                error('CHEBFUN:roots:UnknownOption','Unknown option.')
            end
    end
end

ends = f.ends;
hs = hscale(f);
rs = [];
% rts = []; % All roots will be stored here
rts = f.ends(abs(f.imps(1,:))<tol*hs*f.scl).'; % Zero imps are roots.
% But don't include if function is zero anyway (prevents double counting).
rts(feval(f,rts,'left')<tol*hs*f.scl | feval(f,rts,'right')<tol*hs*f.scl) = [];
realf = isreal(f);
for i = 1:f.nfuns
    b = ends(i+1);
    lfun = f.funs(i);
    if ~zerofun
        % Do not return midpoint of zero funs.
        if any(lfun.vals)
            if rootspref.old
                rs = roots_old(lfun,rootspref); % Get the roots of the current fun
            else
                rs = roots(lfun,rootspref); % Get the roots of the current fun
            end;
        end
    else
        if rootspref.old
            rs = roots_old(lfun,rootspref); % Get the roots of the current fun
        else
            rs = roots(lfun,rootspref); % Get the roots of the current fun
        end
    end
    if ~isempty(rts)
        % Trim out roots that are repeated on either side of the breakpoint.
        while ~isempty(rs) && abs(rts(end)-rs(1))<tol*hs
            rs = rs(2:end);
        end       
    end
    rts = [rts; rs];
    % We add roots at jumps if the sign of the function changes across them.
    if realf && i<f.nfuns && (isempty(rts) || abs(rts(end)-b)>tol*hs )
        rfun = f.funs(i+1);
        if lfun.vals(end)*rfun.vals(1) <= 0,
%             % but not if the function blows up there.
%             if ~(lfun.exps(2) < 0) && ~(rfun.exps(1) < 0)
                rts = [rts; b];
%             end
        end
    end
    rts = sort(rts);
%     if i < f.nfuns && ( isempty(rts) || abs(rts(end)-b) > 1e-14*hs )
%         rfun = f.funs(i+1);
%         fleft = feval(lfun,1); fright = feval(rfun,-1);
%         if real(fleft)*real(fright) <= 0 && imag(fleft)*imag(fright) <= 0
%             rts = [rts; b];
%         end
%     end
end

