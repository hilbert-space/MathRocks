function Fout = define(F,subdom,G)
% DEFINE Supply a new definition for a chebfun on a subdomain.
%
% F = DEFINE(F,S,G) uses the chebfun G to define the chebfun F in the
% domain S. You can specify S as the vector [A,B] or using DOMAIN. If S
% happens to coincide with with an existing breakpoint of F, the impulse
% data (F.imps) is taken from G.
% 
% DEFINE supports expansion/compression: the domain of G is scaled and
% translated to coincide with [A,B]. If G is a scalar numerical value, it
% is expanded into a constant function on [A,B].
%
% If G is nonempty and the domain of F is [C,D], the domain will become
% [min(A,C),max(B,D)]. At any X that is not in [A,B]U[C,D], the new F(X)=0.
%
% If G is an empty chebfun or empty matrix, the corresponding part of the 
% domain of F is deleted. If C<A<B<D, then the gap in the domain that would
% result is filled by translating [B,D] to the left by B-A units. The new
% domain is then [C,D-B+A]. If A<C or B>D, then [A,B] is removed from the
% domain, leaving a single (possibly empty) interval.
%
% An equivalent syntax is F{A,B} = G.
%
% See also CHEBFUN/SUBSASGN, CHEBFUN/RESTRICT.
%
% EXAMPLES
%
%   Sawtooth function:
%     x = chebfun('x'); s = chebfun; for j=-7:2:5, s{j,j+2}=x; end
%
%   Scalar expansion:
%     p = primes(200); f = chebfun;
%     for j = 1:length(p)-1, f{p(j),p(j+1)} = j; end
%    
%   Domain compression:
%     s = chebfun('(3*x+1).*x/4'); f = chebfun;
%     for n=0:8, f{2^(-n-1),1/2^n} = s/2^n; end
%
%   Deletion:
%     f = chebfun('abs(x)'); f{-1/2,1/2} = [];

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


Fout = F;

if isa(subdom,'domain') || isa(G,'chebfun')
    % Define an interval

    % Deal with quasi-matrices.
    if numel(F)~=numel(G), 
        error('CHEBFUN:cumsum:quasidim','Chebfun quasi-matrix dimensions must agree.')
    end
    
    for k = 1:numel(F)
        Fout(k) = definecol(F(k),subdom,G(k));
    end
    
else
    % Define a point
    
    Fout = definecolpoint(F,subdom,G);
    
end

end


function f = definecol(f,subdom,g)
% Deal with a single chebfun.

if isa(subdom,'domain')
  subint = subdom.ends;
else
  subint = subdom;
end

% No change for interval [a,b] with a>b.
if subint(1)>subint(2)    
  return
  % flip
  %g = flipud(g);
  %subint = subint([2 1]);
end


% Convert a scalar or empty input to a chebfun.
if isnumeric(g) 
  if numel(g)==1
    g = chebfun(g);
  elseif numel(g)==0
    g = chebfun;
  else
    error('CHEBFUN:define:badassign',...
      'Must assign to a chebfun, scalar, or empty matrix.')
  end
end

% Transform the domain of g as needed.
if ~isempty(g)                                   % translate
  len = length(domain(g));
  % Avoid translating an interval to what appears to be itself. Doing so
  % can introduce FP errors that can change the domain in a way that breaks
  % equality testing. (Arises in horzcat or subsasgn to a quasimatrix.)
  if any( abs(g.ends([1,end])-subint) > 4*eps*len )
    g.ends = subint(1) + (g.ends-g.ends(1))*diff(subint)/len;
  end
  for j = 1:g.nfuns  % update maps in funs!
      g.funs(j) = newdomain(g.funs(j), g.ends(j:j+1));
  end
end

% Trivial return case.
if isempty(f)
  f = g;
  return
end

% The hard work.
domf = domain(f);
if ~isempty(g)                                 % INSERTION/OVERWRITING
  if subint(2) < domf(1)                       % extension to the left
    f.ends = [ g.ends f.ends ];
    f.funs = [ g.funs fun(0,[g.ends(end) f.ends(1)]) f.funs ];
    f.imps = [ g.imps f.imps ];
  elseif subint(1) > domf(2)                   % extension to the right
    f.ends = [ f.ends g.ends ];
    f.funs = [ f.funs fun(0,[f.ends(end) g.ends(1)]) g.funs ];
    f.imps = [ f.imps g.imps ];
  else                                         % subint intersects domf
      fleft = chebfun; fright = chebfun;
    % The following ifs are for checking the equality cases, since then you
    % get annoying functions defined at just one point. If the restriction
    % operation changes to make that empty, these if tests can disappear.
    if domf(1) < subint(1)
      fleft = restrict(f,[domf(1) subint(1)]);
     end
    if domf(2) > subint(2)
      fright = restrict(f,[subint(2) domf(2)]);
    end
    f.funs = [ fleft.funs g.funs fright.funs ];
    f.ends = [ fleft.ends(1:end-1) g.ends fright.ends(2:end) ];
    f.imps = [ fleft.imps(1:end-1) g.imps fright.imps(2:end) ];
  end
else                                             % DELETION
  if subint(2) < domf(1) || subint(1) > domf(2)
    error('CHEBFUN:define:badremoveinterval',...
      'Interval to be removed is outside the domain.')
  else
    fleft = restrict(f,[domf(1) subint(1)]);
    fright = restrict(f,[subint(2) domf(2)]);
    if isempty(fright), f = fleft;
    elseif isempty(fleft), f = fright;
    else
      % Deletion strictly inside the domain--slide the right side over.
      frightnewends = fright.ends-fright.ends(1)+fleft.ends(end);
      for j = 1:fright.nfuns  % update maps in funs!
        fright.funs(j) = newdomain(fright.funs(j), frightnewends(j:j+1));
      end
      f.funs = [ fleft.funs fright.funs ];
      f.ends = [ fleft.ends(1:end-1) frightnewends ];
      f.imps = [ fleft.imps(1:end-1) fright.imps ];
    end
  end
end

f.nfuns = numel(f.funs);
for k = 1:f.nfuns
    f.scl = max(f.scl, f.funs(k).scl.v);
end

end

function fcol = definecolpoint(f,s,vin)
% Deal with a single chebfun.

col = 1:numel(f);
if isempty(s), fcol = f; return, end

if ~isa(vin,'numeric')
    error('CHEBFUN:subsasgn:conversion',...
            ['Conversion to numeric from ',class(vin),...
            ' is not possible.'])
end
if length(vin) == 1
   vin = vin*ones(length(s),length(col));
elseif length(col) == 1 && min(size(vin)) == 1 && ...
        length(vin)==length(s)
    vin = vin(:);
elseif length(s)~=size(vin,1) || length(col)~=size(vin,2)
    error('CHEBFUN:subsasgn:dimensions',...
            'Subscripted assignment dimension mismatch.')
end
ends = get(f(1),'ends'); a = ends(1); b = ends(end);
if min(s) < a || max(s) > b
    error('CHEBFUN:subsasgn:outbounds',...
        'Cannot introduce endpoints outside domain.')
end
stemp = s;    
s = setdiff(s,ends); impsends = zeros(length(col),2);
for k = 1:length(col)
    impsends(k,:) = f(k).imps(1,[1 end]);
end

% fcol = f;
% for i = 1:length(s)
%     fcol = [restrict(fcol,[a,s(i)]); restrict(fcol,[s(i),b])];
% end 

ss = [a ; s(:) ; b];
% fcol = chebfun;
% for i = 1:length(ss)-1
%     fcol = [fcol ; restrict(f,[ss(i),ss(i+1)])];
% end

fcol = cell(1,length(ss)-1);
for i = 1:length(ss)-1
    fcol{i} = restrict(f,[ss(i),ss(i+1)]);
end
fcol = vertcat(fcol{:});

for k = 1:length(col)
    fcol(k).imps([1 end]) = impsends(k,:);
end
for i = 1:length(col)   
    [mem,loc] = ismember(stemp,fcol(i).ends);
   % fcol(:,i).imps(1,loc(find(loc))) = vin(find(mem),i); 
    fcol(i).imps(1,loc) = vin(mem,i); 
end

% Introduce jumps in the jacobian, but ignore changes introduced by restrict.
for k = 1:numel(f)
    fcol(k).jacobian = anon(['[der2 nonConst] = diff(f,u,''linop'');' ...
        'd = domain(union(f.ends,s)); der = eye(d)*der2;'],{'f','s'},{f(k),s},1,'define');
    fcol(k).ID = newIDnum;
end


end
