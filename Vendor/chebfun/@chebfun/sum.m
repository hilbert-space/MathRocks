function out = sum(F,dim,b)
% SUM	Definite integral or chebfun sum.
% If F is a chebfun, SUM(F) is the integral of F in the interval where it 
% is defined. SUM(F,A,B) integrates F over [A,B], which must be a subset 
% of domain(F).
%
% SUM(F,DIM), where F is a quasimatrix, sums along the dimension DIM. Summing 
% in the chebfun dimension computes a definite integral of each chebfun; 
% summing in the indexed dimension adds together all of the chebfuns to
% return a single chebfun. For a column quasimatrix, SUM(F) is the same as 
% SUM(F,1).
%
% Examples:
%   x = chebfun('x',[0 1]);
%   sum(x)      % returns 1/2
%   A = [x.^0 x.^1 x.^2];  
%   sum(A)      % integrates three functions
%   sum(A,2)    % returns the chebfun for 1+x+x^2
%   sum(A.',2)  % transpose of sum(A,1)
%
% See also sum.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(F), out = 0; return, end    % empty chebfun has sum 0

subint = false;
if nargin == 3
    a = dim; subint = true;
elseif nargin == 1
    % nothing to do here
elseif isa(dim,'domain')
    dim = dim.ends; a = dim(1); b = dim(end); subint = true;
elseif numel(dim) > 1
    a = dim(1); b = dim(end); subint = true;
end

% Deal with subinterval case.
if subint
    out = sum_subint(F,a,b);
    return
end

F_trans = F(1).trans;                  % default sum along columns
if (nargin == 1) || (nargin == 3)
    if min(size(F))==1 && F_trans
       dim = 2;                        % ...except for single row chebfun
    else
       dim = 1;
    end 
end

if F_trans
  F = transpose(F);
  dim = 3-dim;
end

if dim==1
  if F(1).funreturn
      out = chebconst;
  else
      out = zeros(1,size(F,2));
  end
  for k = 1:size(F,2);
    out(k) = sumcol(F(k));
  end
else
  out = F*ones(size(F,2),1);
end
  
if F_trans
  out = transpose(out);
end

% ------------------------------------------
function out = sumcol(f)

if isempty(f), out = 0; return, end

% Things can go wrong with blowups.
exps = get(f,'exps');
for k = 1:f.nfuns
    if any(exps(k,:) <= -1)
        f.funs(k) = extract_roots(f.funs(k),[],exps(k,:)<=-1);
        exps(k,:) = get(f.funs(k),'exps');
    end
end

if any(any(exps<=-1)),
    
   % Get the sign at these blowups
   expsl = find(exps(:,1)<=-1);
   expsr = find(exps(:,2)<=-1);
   sgn = zeros(length(expsl)+length(expsr),1);
   for k = 1:length(expsl), sgn(k) = sign(f.funs(expsl(k)).vals(1)); end
   for k = 1:length(expsr), sgn(length(expsl)+k) = sign(f.funs(expsr(k)).vals(end)); end
   
   % If these aren't all the same, then we can't compute
   if length(unique(sgn)) > 1 || any(isinf(get(f,'ends')))
       out = NaN;
%         warning('CHEBFUN:sum:NaN',['Integrand diverges to infinity on domain ', ...
%         'and chebfun cannot compute its sum. (Principal value integrals are not ', ...
%         'currently supported).']);
   else
       % Here we can determine the sign of the blowup
       out = sgn(1).*inf;
   end
   
else

    out = 0;
    % Sum on each fun
    for i = 1:f.nfuns
        out = out + sum(f.funs(i));
        if isnan(out), break, end % This shouldn't happen, but if it does, bail out.
    end

    % Deal with impulses
    if (size(f.imps,1) >= 2)
        % only add the delta functions, since the integral of 
        % derivatives of delta functions is always zero.
        out = out + sum(f.imps(2,:));
    end
    
end

if f.funreturn   % fun-output mode switch
    out = chebconst(out,domain(f));
    out.jacobian = anon(['[der1,nonConst] = diff(f,u,''linop''); '...
                         'der = sum(domain(f))*der1;'],...
                         {'f'},{f},1,'sum');
    out.funreturn = 1;
end

% ------------------------------------------
function out = sum_subint(F,a,b)
[d1 d2] = domain(F);
if isnumeric(a) && isnumeric(b)
    if a < d1 || b > d2
        error('CHEBFUN:sum:ab','Interval outside of domain.');
    end
    if a == d1 && b == d2
        out = sum(F);
        return
    end
    out = cumsum(F);
    out = feval(out,b)-feval(out,a);
    if F.funreturn
        % There's actually no need to introduce a breakpoint.
%         out.jacobian = anon(['[der1,nonConst] = diff(f,u,''linop''); '...
%             'der = sum(domain(a,b))*restrict(domain(f),domain(a,b))*der1;'],...
%             {'f','a','b'},{F,a,b},1,'sum');
        out.funreturn = 1;
     end
elseif isa(a,'chebfun') && isa(b,'chebfun')
    out = cumsum(F);
    out = compose(out,b)-compose(out,a);
elseif isa(b,'chebfun')
    if a < d1 
        error('CHEBFUN:sum:a','Interval outside of domain.');
    end
    out = cumsum(F);
    if norm(chebfun('x',domain(b),2)-b) == 0
        out = out - feval(out,a);
    else
        out = compose(out,b)-feval(out,a);
    end
elseif isa(a,'chebfun')
    if b > d2
        error('CHEBFUN:sum:b','Interval outside of domain.');
    end
    out = cumsum(F);
    out = feval(out,b)-compose(out,a);
end
