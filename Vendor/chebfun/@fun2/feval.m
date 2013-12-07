function v = feval(f,x,y,varargin)
%FEVAL evaluation of a fun2. 
% 
% FEVAL(F,X,Y) evaluates a F at (X,Y).

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

warning('off', 'MATLAB:divideByZero'); % TODO: Delete this.

pref2 = chebfun2pref;

if ( nargin == 1 ) 
    error('FUN2:feval:nargin','Not enough inputs'); 
end

if ( nargin == 2 && isnumeric(x) )
    if ( size(x,2) == 2 )
        y = x(:,2); x = x(:,1);
    elseif ( size(x,1) == 2 )
        y = x(2,:); x = x(1,:);
    else
        error('FUN2:feval:nargin','Not enough inputs');
    end
end

if ( ~all(size(x)==size(y)) )
    if ( length(x) == 1 )
        x = repmat(x(:),size(y));
    elseif ( length(y) == 1 )
        y = repmat(y(:),size(x));
    else
        error('FUN:feval:inputs','inconsistent inputs')
    end
end

takediag = 0 ;
if ( nargin == 3 && isnumeric(x) && isnumeric(y) )       
       if ( min(size(x))>1 && all(size(x) == size(y)) )
          % at this point x and y should come from meshgrid. 
           x = x(1,:); y = y(:,1);
       else
           takediag = 1;    % take diagonal at the end. 
           nx = size(x,1);  % is x a column or row.
       end
end

% x is row and y should be column.
x = transpose(x(:)); y = y(:);

% Extract CUR factorisation. 
C = get(f,'C'); R = get(f,'R'); Pivots = get(f,'U'); 
% Evaluate columns and rows.
if ( pref2.mode )
    c = C(y,:); r = R(:,x);
else
    % No chebfuns in column so just form funs. 
%     c = zeros(length(y),size(C,2));
    d = getdomain(f); 
    
    % evaluate columns. 
    [xx,ignored,vv]=chebpts(size(C,1),d(3:4));
    vv = vv(:,ones(length(y),1))./(y(:,ones(length(xx),1)).'-xx(:,ones(length(y),1))); 
    [repx repy] = find(abs(vv)==inf); sumv = sum(vv).'; 
    c=(vv.'*C)./sumv(:,ones(size(C,2),1));
    if ~isempty(repy), c(repy,:) = C(repx,:); end 
    
     % evaluate rows
     x = x.';
    [xx,ignored,vv]=chebpts(size(R,2),d(1:2));
    vv = vv(:,ones(length(x),1))./(x(:,ones(length(xx),1)).'-xx(:,ones(length(x),1))); 
    [repx repy] = find(abs(vv)==inf); sumv = sum(vv).'; 
%     r=(R*vv)./sum(vv);
    r=(R*vv).'./sumv(:,ones(size(R,1),1)); 
    if ~isempty(repx), r(repy,:) = R(:,repx).'; end;r = r.';
end

% catch for the zero function. 
if f.rank == 0, Pivots = 1; v = zeros(size(c,2),size(r,1)); return; end

% Evaluate the approximant.
v = c*(diag(1./Pivots)*r);

if ( takediag == 1 )
    v = diag(v); 
    if ( nx > 1 )
        v = v(:); 
    else
        v = v(:).';
    end
end

end
    
