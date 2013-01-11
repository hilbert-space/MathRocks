function [y,x] = min(f,g,dim)
% MIN   Minimum value or pointwise min of chebfuns.
%
% MIN(F) returns the minimum value of the chebfun F. 
%
% [Y,X] = MIN(F) also returns the argument (location) where the minimum 
% value is achieved. Multiple locations are not found reliably. 
%
% [Y,X] = MINANDMAX(F,'local') returns not just the global minimum and 
% its position, but all of the local minima.
% 
% H = MIN(F,G), where F and G are chebfuns defined on the same domain,
% returns a chebfun H such that H(x) = min(F(x),G(x)) for all x in the
% domain of F and G. Either F or G may be a scalar.
%
% [Y,X] = MIN(F,[],DIM) operates along the dimension DIM of the quasimatrix
% F. If DIM represents the continuous variable, then Y and X are vectors.
% If DIM represents the discrete dimension, then Y is a chebfun and X is
% undefined. The default for DIM is 1, unless F has a singleton dimension,
% in which case DIM is the continuous variable. 
%
% If F or G is complex-valued, absolute values are taken to determine
% minima, but the resulting values correspond to those of the original
% function(s).
%
% See also CHEBFUN/MAX. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin==2
  if strcmpi(g,'local') 
      if numel(f) == 1
          [y x] = localmin(f);
          return
      else
          error('CHEBFUN:min:localmin','''local'' min is not defined for quasimatrices');
      end
  end
  if nargout > 1
    error('CHEBFUN:min:twoout',...
      'Min with two inputs and two outputs is not supported.')
  end
  y = minfun(f,g);
else   % 1 or 3 inputs
  % Provide a default for the dim argument.
  if nargin==1
    % For a single row chebfun, let dim=2. Otherwise, dim=1. 
    % This is consistent with MAX/MIN for matrices.
    if numel(f)==1 && f.trans
      dim = 2;
    else
      dim = 1;
    end
  end
  
  % Translate everthing to column quasimatrix. 
  if f(1).trans 
    dim = 3-dim; 
  end
  
  allreal = isreal(f);
  
  if dim==1
    % Take the min in the continuous variable. 
    for k = 1:numel(f)
      if allreal
        [yk,xk] = minval(f(k));
        y(1,k) = yk;  x(1,k) = xk;
      else
        [yk,xk] = minval(abs(f(k)));
        x(1,k) = xk;  y(1,k) = feval(f(k),xk);  
      end        
    end
    if f(1).trans
      y = y.'; x = x.';
    end
  elseif dim==2
    % Return the composite min function.
    y = f(1);
    for k = 2:numel(f)
      if allreal
        y = minfun(y,f(k));
      else
        y = minfun(y,f(k),1);
      end
    end
  end
  
end

end  % min function

function h = minfun(f,g,ignored)
% Return the function h(x)=min(f(x),g(x)) for all x.
% If one is complex, use abs(f) and abs(g) to determine which function
% values to keep. (experimental feature)
if isreal(f) && isreal(g) && nargin<3
  [f g] = overlap(f,g);
  Fs = sign(f-g);
else
  Fs = sign(abs(f)-abs(g));
end
h = ((1-Fs)/2).*f + ((1+Fs)/2).*g;

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
        if any(get(h.funs(k-1),'exps') < 0)
            h.funs(k-1) = extract_roots(h.funs(k-1));
        end
        if smooth(k) && ~any(h.funs(k).exps) && ~any(h.funs(k-1).exps)
            % decides which piece is shorter and assume that is the more
            % accurate one
            if h.funs(k-1).n < h.funs(k).n && h.funs(k-1).vals(end)
               h.funs(k).vals(1) = h.funs(k-1).vals(end);
            else
               h.funs(k-1).vals(end) = h.funs(k).vals(1);
            end
            % Take the value that is largest
%             if h.funs(k-1).vals(end) > h.funs(k).vals(1)
%                 h.funs(k).vals(1) = h.funs(k-1).vals(end);
%             else
%                 h.funs(k-1).vals(end) = h.funs(k).vals(1);
%             end
            if isfinite(h.funs(k-1).vals(end))
                h.imps(1,k) = h.funs(k-1).vals(end);
            else
                h.imps(1,k) = h.funs(k).vals(1);
            end
        end
    end  
end

end

function [y,x] = minval(f)
% Return the value and argument of a min.

% If there is an impulse, return inf
ind = find(min(f.imps(2:end,:),[],1)<0,1,'first');
if ~isempty(ind), y = -inf; x = f.ends(ind); return, end

ends = f.ends;
y = zeros(1,f.nfuns); x = y;
for i = 1:f.nfuns
  %a = ends(i); b = ends(i+1);
  [o,p] = min(f.funs(i));
  y(i) = o;
  x(i) = p;
end
[y,I] = min(y);
x = x(I);

%Check values at end break points
ind = find(f.imps(1,:)<y);
if ~isempty(ind)
  [y, k] = min(f.imps(1,ind));
  x = ends(ind(k));
end

end

function [y x] = localmin(f)
    % Compute the turning points
    df = diff(f);
    x = roots(df);
    % Detect the minima
    idx = feval(diff(df),x) > 0;
    x = x(idx);
    
    % Deal with the end-points
    d = domain(f);
    xends = d.ends([1 end]);
    dfends = feval(df,xends);
    if dfends(1)>0  && ((~isempty(x) && xends(1) ~= x(1)) || isempty(x))
        x = [xends(1) ; x];
    end
    if dfends(2)<0 && ((~isempty(x) && xends(2) ~= x(end)) || isempty(x))
            x = [x ; xends(2)];
    end
    
    y = feval(f,x);
end


