function [y,x] = minandmax(f,dim)
% MINANDMAX Minimum and maximum values of a chebfun.
%
% Y = MINANDMAX(F) returns the range of the chebfun F such that 
% Y(1) = min(F) and Y(2) = max(F). 
%
% [Y X] = MINANDMAX(F) returns also points X such that F(X(j)) = Y(j), j =
% 1,2.
%
% [Y X] = MINANDMAX(F,'local') returns not just the global minimum and 
% maximum values, but all of the local extrema (i.e. local min and max).
%
% Y = MINANDMAX(F,DIM) operates along the dimension DIM of the quasimatrix
% F. If DIM represents the continuous variable, then Y is a vector.
% If DIM represents the discrete dimension, then Y is a quasimatrix.
% The default for DIM is 1, unless F has a singleton dimension,
% in which case DIM is the continuous variable. 
%
% If F is complex-valued, absolute values are taken to determine extrema, 
% but the resulting values correspond to those of the original function.
%
% See also CHEBFUN/MAX, CHEBFUN/MIN. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Provide a default for the dim argument.
ftrans = f(1).trans;

if nargin==1
    % For a single row chebfun, let dim=2. Otherwise, dim=1. 
    % This is consistent with MAX/MIN for matrices.
    if numel(f)==1 && ftrans
      dim = 2;
    else
      dim = 1;
    end
end

if strcmpi(dim,'local') 
  if numel(f) == 1
      [y x] = localminandmax(f);
      return
  else
      error('CHEBFUN:minadmax:localminandmax','''local'' minandmax is not defined for quasimatrices');
  end
end

% Translate everthing to column quasimatrix. 
if ftrans 
    dim = 3-dim; 
end

allreal = true;
if ~isreal(f)
     allreal = false;
end
    
if dim == 1
    % Take the max in the continuous variable. 
    nf = numel(f);
    y = zeros(2,nf);  x = y;
    for k = 1:numel(f)
        if allreal
            [yk,xk] = mmval(f(k));
            y(:,k) = yk;  x(:,k) = xk;       
        else
            [yk,xk] = mmval(abs(f(k)));
            y(:,k) = feval(f(k),xk);  x(:,k) = xk;
        end
            
    end
    if ftrans
      y = y.'; x = x.';
    end
    return
end
      
if dim == 2
    % Return the composite max function.
    if nargout > 1
        error('CHEBFUN:minandmax:dim2outs',['Only single output if ', ...
        'taking min/max in the discrete dimension']);
    end
    if ftrans
      f = f.';
    end
    y = [f(1) f(1)];
    for k = 2:numel(f)
        if allreal
            y(:,1) = minfun(y(:,1),f(k));
            y(:,2) = maxfun(y(:,2),f(k));
        else
            y(:,1) = minfun(y(:,1),f(k),1);
            y(:,2) = maxfun(y(:,2),f(k),1);
        end
    end
    if ftrans
        y = y.';
    end
end

end  % minandmax function

function [y,x] = mmval(f)

y = [inf -inf];
x = [inf inf];

% negative impulse, return y(1) = -inf
ind = find(min(f.imps(2:end,:),[],1)<0,1,'first');
if ~isempty(ind), y(1) = -inf; x(1) = f.ends(ind); end
% positive impulse, return y(2) = -inf
ind = find(max(f.imps(2:end,:),[],1)>0,1,'first');
if ~isempty(ind), y(2) = inf; x(2) = f.ends(ind); end

if all(isfinite(x)), return, end
    
ends = f.ends;
yy = [zeros(f.nfuns,2) ; y];
xx = [zeros(f.nfuns,2) ; x];
for i = 1:f.nfuns
  %a = ends(i); b = ends(i+1);
  [yk, xk] = minandmax(f.funs(i));
  yy(i,:) = yk;
  xx(i,:) = xk;
end
[y(1),I1] = min(yy(:,1));
[y(2),I2] = max(yy(:,2));

x(1) = xx(I1,1); x(2) = xx(I2,2);

%Check values at end break points
ind = find(f.imps(1,:) < y(1));
if ~isempty(ind)
  [y(1), k] = min(f.imps(1,ind));
  x(1) = ends(ind(k));
end

%Check values at end break points
ind = find(f.imps(1,:) > y(2));
if ~isempty(ind)
  [y(2), k] = max(f.imps(1,ind));
  x(2) = ends(ind(k));
end

end

function h = maxfun(f,g,ignored)
% Return the function h(x)=max(f(x),g(x)) for all x.
% If one is complex, use abs(f) and abs(g) to determine which function
% values to keep. (experimental feature)
if isreal(f) && isreal(g) && nargin<3
  Fs = sign(f-g);
else
  Fs = sign(abs(f)-abs(g));
end
h = ((Fs+1)/2).*f + ((1-Fs)/2).*g ;

% make sure jumps are not introduced in endspoints where f and g are
% smooth.
if isnumeric(f)
    [pjump, loc] = ismember(h.ends(1:end), g.ends);
elseif isnumeric(g)
    [pjump, loc] = ismember(h.ends(1:end), f.ends);
else
    [pjump, loc] = ismember(h.ends(1:end), union(f.ends,g.ends));
end
smooth = ~loc; % Location where endpints where introduced.
% If an endpoint has been introduced, make sure h is continuous there
if any(smooth)
    for k = 2:h.nfuns
        if smooth(k)
            % decides which pice is shorter and assume that is the more
            % accurate one
            if h.funs(k-1).n < h.funs(k).n
                h.funs(k).vals(1) = h.funs(k-1).vals(end);
            else
                h.funs(k-1).vals(end) = h.funs(k).vals(1);
            end
            h.imps(1,k) = h.funs(k-1).vals(end);
        end
    end  
end
end

function h = minfun(f,g,ignored)
% Return the function h(x)=min(f(x),g(x)) for all x.
% If one is complex, use abs(f) and abs(g) to determine which function
% values to keep. (experimental feature)
if isreal(f) && isreal(g) && nargin<3
      Fs = sign(f-g);
else
      Fs = sign(abs(f)-abs(g));
end
h = ((1-Fs)/2).*f + ((1+Fs)/2).*g ;
end

function [y x] = localminandmax(f)
    % Compute the turning points
    df = diff(f);
    x = roots(df);
    
    % Deal with the end-points
    d = domain(f);
    xends = d.ends([1 end]);
    dfends = feval(df,xends);
    if dfends(1)~=0
        x = [xends(1) ; x];
    end
    if dfends(2)~=0
            x = [x ; xends(2)];
    end
    
    y = feval(f,x);
end
