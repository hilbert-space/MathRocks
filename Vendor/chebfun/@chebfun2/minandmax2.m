function [Y,X] = minandmax2(f)
%MINANDMAX2, find global minimum and maximum of a chebfun2.
%
% Y=minandmax2(F) returns the minimum and maximum value of a chebfun2 over
% its domain. Y is a vector of length 2 such that Y(1) = min(f(x,y)) and
% Y(2) = max(f(x,y)).
%
% [Y X]=minandmax2(F) also returns the position of the minimum and maximum.
% That is,
%
%  F(X(1,1),X(1,2)) = Y(1)     and      F(X(2,1),X(2,2)) = Y(2).
%
% For high accuracy results this command requires the Optimization Toolbox.
%
% See also MAX2, MIN2, NORM.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
    return;
end

maxsize = 4e3;   % Maximum possible sample matrix size.
pref2 = chebfun2pref;
% Is the function the zero function?
if norm(f.fun2.U)<10*eps
    rect = f.corners;
    X=[(rect(2)+rect(1))/2 (rect(4)+rect(3))/2];X=[X;X];
    Y=[0;0];
    return
end

rect=f.corners;
if length(f) == 1  % rank-1 is easy:
    % We can find it from taking maximum and minimum in x and y direction.
    %share out the scaling.
    if pref2.mode
        fun = f.fun2; R = fun.R; C = fun.C; U=fun.U;
    else
        rect=f.corners;
        fun = f.fun2;
        R = chebfun(fun.R.',rect(1:2)).';
        C = chebfun(fun.C,rect(3:4));
        U=fun.U;
    end
    sgn = sign(U).'; sq = 1./sqrt(abs(U)); R = R.*sq.'.*sgn; C = C.*sq; % share out scaling
    [yr xr] = minandmax(R); [yc xc] = minandmax(C);  % Call Chebfun minandmax.
    vv = [yr(1)*yc(1), yr(1)*yc(2), yr(2)*yc(1), yr(2)*yc(2)];  % convex hull
    [Y(2) indmx] = max(vv); [Y(1) indmn] = min(vv);
    % Work out the location of the maximum.
    X = zeros(2); X(1,1) = xr(2); X(1,2) = xc(2);
    if indmn <= 2, X(1,1) = xr(1); end
    if mod(indmn,2) == 1, X(1,2) = xc(1); end
    X(2,1) = xr(2); X(2,2) = xc(2);
    if indmx <= 2, X(2,1) = xr(1);end
    if mod(indmx,2) == 1, X(2,2) = xc(1); end
    return
elseif length(f) <= maxsize 
    % We are looking for a fast initial guess.  So we first truncate the
    % chebfun2.
    fun = f.fun2; R = fun.R; C = fun.C; U=fun.U;
    if pref2.mode
        r = get(R,'vals'); for k=1:length(r), RR(k,:) = r{k}'; end; R=RR;
        c = get(C,'vals'); for k=1:length(c), CC(k,:) = c{k}'; end; C=CC;
    end
    % Used to truncate to low rank if possible... could be a good idea...
    % not sure. 
%     take = find((abs(U)>1e-2*fun.scl),1,'last');  % reduce rank
%     take = max(take,2);   % don't reduce to rank-1.
    take = length(f); 
    if take <= 3 && (length(C)>100 && length(R)>100)
        % In this case the convex-hull algorithm is faster than max
        R = R(1:take,:); C = C(:,1:take); U = U(1:take);
        rect = f.corners;        % get domain.
        
        sgn = sign(U).'; sq = 1./sqrt(abs(U)); R = diag(sq.'.*sgn)*R; C = C*diag(sq); % share out scaling
        lenx = length(R); leny=length(C);  % size to discretise.
%         lenx = min(lenx,maxsize); leny = min(leny,maxsize);
        xpts =chebpts(lenx,rect(1:2));
%         rvals = R(:,xpts).';               % evaluate to discretize.
        ypts =chebpts(leny,rect(3:4));
%         cvals = C(ypts,:);
        rvals = R.'; cvals = C; 
        k = convhull(rvals); k = unique(k); % Compute convex hull of rows.
        rvals = rvals(k,:); xpts = xpts(k,:);
        
        k = convhull(cvals); k = unique(k); % Compute convex hull of columns
        cvals = cvals(k,:);ypts = ypts(k,:);
    elseif length(C) <= maxsize && length(R) <= maxsize
        % O(n^2) algorithm is faster... just evaluate
        sgn = sign(U).'; sq = 1./sqrt(abs(U)); R = diag(sq.'.*sgn)*R; C = C*diag(sq); % share out scaling
        lenx = length(R); leny=length(C);  % size to discretise.
        xpts =chebpts(lenx,rect(1:2));  
        ypts =chebpts(leny,rect(3:4));
        rvals = R.'; cvals = C;
    else
        error('Chebfun2:max:length','Columns and rows are too long.');
    end
    
    A = cvals*rvals.';
    % Maximum entry in discretisation.
    [ignored,ind]=min(A(:)); [row,col]=ind2sub(size(A),ind);
    X(1,1) =xpts(col);  X(1,2) = ypts(row); Y(1) = feval(fun,X(1,1),X(1,2));
    % Minimum entry in discretisation.
    [ignored,ind]=max(A(:)); [row,col]=ind2sub(size(A),ind);
    X(2,1) =xpts(col);  X(2,2) = ypts(row); Y(2) = feval(fun,X(2,1),X(2,2));
    
    % Get more digits with optimisation algorithms.
    lb = [rect(1);rect(3)]; ub = [rect(2);rect(4)];
    % If the optimization toolbox is available then use it to get a better
    % maximum.

   
%     try
        try 
            warnstate = warning;
            warning('off'); % disable verbose warnings from fmincon.
            options = optimset('Display','off','TolFun', eps, 'TolX', eps);
            [mn Y(1)] = fmincon(@(x,y) feval(f,x(1),x(2)),X(1,:),[],[],[],[],lb,ub,[],options);
            [mx Y(2)] = fmincon(@(x) -feval(f,x(1),x(2)),X(2,:),[],[],[],[],lb,ub,[],options);
            Y(2) = -Y(2);  X(1,:)=mn; X(2,:)=mx;    
            warning(warning);
        catch
            % Nothing is going to work so initial guesses will have to do.
            mn = X(1,:); mx = X(2,:);
%             warning('on');
%             warning('CHEBFUN2:MINANDMAX2','Unable to find Matlab''s optimization toolbox so results will be inaccurate.');
        end
%     catch
%         % This will work if optimset and fminsearch is on the matlab path.
%         options = optimset('Display','off','TolFun', eps, 'TolX', eps);
%         [mn Y(1)] = optimize(@(x,y) feval(f,x(1),x(2)),X(1,:),lb',ub',[],[],[],[],[],[],options);
%         [mx Y(2)] = optimize(@(x,y) -feval(f,x(1),x(2)),X(2,:),lb',ub',[],[],[],[],[],[],options);
%         Y(2) = -Y(2);  X(1,:)=mn; X(2,:)=mx;
%     end

elseif length(f) >= maxsize
    error('Chebfun2:max:length','Rank is too large.');
end


end