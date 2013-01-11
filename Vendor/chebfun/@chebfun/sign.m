function Fout = sign(F,varargin)
% SIGN   Sign function.
% G = SIGN(F) returns a piecewise constant chebfun G such that G(x) = 1 in
% the interval where F(x)>0, G(x) = -1 in the interval where F(x)<0 and
% G(x) = 0  in the interval where F(x) = 0. The breakpoints of H are
% introduced at zeros of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    Fout = F;
    for k = 1:numel(F)
        Fout(k) = signcol(F(k),varargin{:});
    end

    for k = 1:numel(F)
    %     Fout(k).jacobian = eval('jacerror');
        Fout(k).jacobian = anon('diag1 = diag(0*Fout); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero; if(any(nonConst)), warning(''chebfun:noADsupport'',''Chebops and AD do not support the abs nor sign method in the unknown function(s)/the functions being differentiated with respect to.''),warning(''off'',''chebfun:noADsupport''),end',{'Fout','F'},{Fout(k),F},1,'sign');
        Fout(k).ID = newIDnum;
    end

% function varargout = jacerror
% error('CHEBFUN:sign:jac','sign function is not Frechet differentiable.');


% ----------------------------------
function fout = signcol(f,varagin)

    if isempty(f), fout = chebfun; return, end
    f.funreturn = 0;
    funreturn = f.funreturn;

    % If f is not real, sign returns f.
    if ~isreal(get(f,'vals'))
        fout = f; return
    % If f is zero Chebfun, then return zero.
    elseif ~any(get(f,'vals'))
        imps = sign(double(f.imps(1,:)));
        idx = logical(imps); idx([1 end]) = true;
        ends = f.ends(idx);
        fout = chebfun(0,ends);
        fout.imps = imps(idx);
        return
    end

    r = roots(f,'nozerofun');
    ends = f.ends;
    hs = hscale(f);
    tol = 100*chebfunpref('eps')*f.scl;

    if isempty(r), 
    %     fout = chebfun(sign(f.funs(1).vals(1)),[ends(1) ends(end)]);
    %     if f.trans, fout = transpose(fout); end
    %     return
        r = ends([1 end]).';
    else
        if abs(r(1)  - ends(1)  ) > 1e-14*hs, r = [ends(1); r  ]; end 
        if abs(r(end) - ends(end)) > 1e-14*hs, r = [r; ends(end)];  end
    end

    % check for double roots (double roots may be quite far apart)
    ind = find(diff(r) < 1e-7*hs); cont = 1; 
    while ~isempty(ind) && cont < 3
        remove = false(size(r));
        for k = 1:length(ind)
            % Check whether a double root or two single roots close close
            if abs(feval(f,mean(r(ind(k):ind(k)+1)))) < tol
               remove(ind+1) = true;
            end
        end
        r(remove) = [];
        cont = cont+1;
        ind = find(diff(r) < 1e-7*hs);
    end

    % -------------------------------------------
    % Make sure that the domain of definition is not changed
    % Rodp added this to fix a bug -- Wiki 22/4/08.
    r(end) = ends(end);
    r(1) = ends(1);
    %---------------------------------------------

    if nargin == 1
        % Non-trivial impulses should not be removed
        lvals = ends; for k=1:length(ends)-1, lvals(k) = f.funs(k).vals(1); end; lvals(end) = f.funs(end).vals(end);
        rvals = ends; for k=2:length(ends), rvals(k) = f.funs(k-1).vals(end); end; rvals(1) = f.funs(1).vals(1);
        idxl = abs(f.imps(1,:) - lvals) > 100*tol;
        idxr = abs(f.imps(1,:) - rvals) > 100*tol;
        idx = idxl | idxr; idx([1 end]) = 1;
        r = sort(unique([r ; ends(idx).']));
        [ignored idx2] = intersect(r,ends(idx));
    end

    % Build new chebfun
    nr = length(r);
    ff = {};
    c = 0.5912; % evaluate at an arbitrary point in [a,b]
    vals = sign( feval( f , c*r(1:nr-1) + (1-c)*r(2:nr) ) );
    for i = 1:nr-1
        ff{end+1} = { vals(i) , r(i:i+1) };
    end
    fout = set( f , 'funs' , fun( ff ) , 'ends' , r , 'scl' , 1 , 'imps' , zeros(1,nr) );

    % Reassign impulses
    if nargin == 1
        fout.imps(1,idx2) = sign( f.imps(idx) );
    else
        fout.imps(1,:) = sign( double( feval( f , r ) ) );
    end
    fout.funreturn = funreturn;
    
