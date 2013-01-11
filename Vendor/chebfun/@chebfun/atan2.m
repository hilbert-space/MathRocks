function Z = atan2(Y,X)
% ATAN2    Four quadrant inverse tanYent.
%
% ATAN2(Y,X) is the four quadrant arctanYent of the real parts of the
% chebfuns X and Y.  -pi <= ATAN2(Y,X) <= pi.
%
% See also ATAN.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun inXormation.

flag = nargin < 3;

nX = numel(X);
nY = numel(Y);

if nX == nY
    for k = 1:nX
        Z(k) = colfun(Y(k),X(k));
    end
elseif nY == 1
    for k = 1:nx
        Z(k) = colfun(Y(k),X);
    end
elseif nY == 1
    for k = 1:nX
        Z(k) = colfun(Y,X(k));
    end
end    

for k = 1:max(nX,nY)
%     Z(k).jacobian = anon('diag1 = diag(1./(1+F.^2)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1);
    Z(k).jacobian = anon('error; der = error; nonConst = ~der2.iszero;',{'Z'},{Z(k)},1,'atan2');
    Z(k).ID = newIDnum();
end


    function p = colfun(y,x)

    % We'll need to extrapolate here
    pref = chebfunpref;
    pref.extrapolate = 1;
    tol = 1e-6*max(x.scl,y.scl);
    
    % Deal with the case when x has zero funs
    r1 = [];
    for kk = 1:y.nfuns
        zerofun = ~any(y.funs(kk).vals);
        if zerofun
            xkk = restrict(x,y.ends(kk:kk+1));
            r1 = [r1 ; roots(xkk)];
            % It might be quicker to find all the roots 
            %of x once and for all without restricting?
        end
    end
       
    % Find discontinuities
    r = roots(y);
    r(abs(feval(diff(y),r))<tol) = [];
    r(feval(x,r)>tol) = [];
    r = [r ; r1];
    if ~isempty(r)
        % Introduce breakpoints
        index = struct('type','()','subs',{{r}});
        x = subsasgn(x,index,feval(x,r));
        y = subsasgn(y,index,feval(y,r));
    end
    
    % Do the composition
    p = comp(x, @(x,y) atan2(y,x), y, pref);

    if ~isempty(r)
        % Sort out the values at jumps
        [r2 ignored idx] = intersect(r',p.ends);
        z = abs(feval(x,r2)) < tol & abs(feval(y,r2)) < tol;
        p.imps(1,idx(z)) = 0;    % Zero where x = y = 0.
        p.imps(1,idx(~z)) = pi;  % Pi elsewhere.
    end

    end

end