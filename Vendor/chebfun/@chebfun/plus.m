function H = plus(F1,F2)
% +	  Plus.
%
% F + G adds chebfuns F and G, or a scalar to a chebfun if either F or G is 
% a scalar.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (isempty(F1) || isempty(F2)), H=chebfun; return; end

if isa(F1,'double')
    H = F2;
    if numel(F1) ~= 1 && ~all(size(F1) == size(F2) | (isinf(size(F2)) & size(F1)==1))
        error('CHEBFUN:plus:sclsize','Matrix dimensions do not agree.'); 
    end
    if numel(F1) == 1
        F1 = repmat(F1,1,numel(F2)); 
    end
    for k = 1:numel(F2)
        H(k) = pluscol(F1(k),F2(k));
    end
elseif isa(F2,'double')
    H = F2 + F1;
else
    if any(size(F1)~=size(F2))
        error('CHEBFUN:plus:size','Quasimatrix dimensions must agree.')
    end
    if isa(F2,'chebconst')
        H = F1;
    else
        H = F2;
    end
    for k = 1:numel(F2)
        H(k) = pluscol(F1(k),F2(k));
    end
end        



% --------------------------------------------
function h =  pluscol(f1,f2)

% scalar + chebfun
if isa(f1,'double')
    h = f2;
    for i = 1: f2.nfuns
          h.funs(i) = f1 + f2.funs(i);  
    end
    h.imps(1,:) = f1 + f2.imps(1,:);
    h.scl = max(h.scl, abs(f1+h.scl));
    
elseif isa(f2,'double')
    h=f1;
    for i = 1: f1.nfuns
        h.funs(i)=f1.funs(i) + f2;
    end
    h.imps(1,:) = f2 + f1.imps(1,:);
    h.scl = max(h.scl, abs(f2+h.scl));

else    
    funreturn = f1.funreturn || f2.funreturn;
    % chebfun + chebfun
    [f1,f2] = overlap(f1,f2);   
    h = f1;
    scl = h.scl;
    for k = 1:f1.nfuns
        h.funs(k) = f1.funs(k) + f2.funs(k);
        scl = max(scl, h.funs(k).scl.v);
    end
    h.imps = f1.imps+f2.imps;

    % update scale
    for k = 1:f1.nfuns
        h.funs(k).scl.v = scl;
    end
    h.scl = scl;
    
    if isa(f1,'chebconst') && ~isa(f2,'chebconst')
        f1.jacobian = anon('[der nonConst] = diff(f,u,''linop''); der = promote(der);',{'f'},{f1},1,'promote');
        f1.ID = newIDnum();
    elseif isa(f2,'chebconst') && ~isa(f1,'chebconst')
        f2.jacobian = anon('[der nonConst] = diff(f,u,''linop''); der = promote(der);',{'f'},{f2},1,'promote');
        f2.ID = newIDnum();
    end

    h.jacobian = anon('[der1 nonConst1] = diff(f1,u,''linop''); [der2 nonConst2] = diff(f2,u,''linop''); der = der1 + der2; nonConst = nonConst1 | nonConst2;',{'f1' 'f2'},{f1 f2},1,'plus');
    h.ID = newIDnum();
    h.funreturn = funreturn;
    
end




