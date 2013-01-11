function H = and(F,G)
% &   Chebfun Logical AND
%
% A & B performs a logical AND of chebfuns A and B and returns a
% chebfun containing elements set to either logical 1 (TRUE) or logical
% 0 (FALSE).  An element of the output chebfin is set to 0 if both
% input chebfuns contains a non-zero element at that same point.
% Otherwise, that element is set to 0.  A and B must have the same
% dimensions unless one is a scalar.
    
% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check for emptiness
if isempty(F) || isempty(G)
    H = F;
end

% Deal with scalar inputs. (This is a bit lazy...)
if isnumeric(F)
    tmp = F; F = chebfun;
    for k = 1:numel(F)
        F(k) = chebfun(tmp(k),G.ends([1 end]));
    end
    if G.trans, F = transpose(F); end
elseif isnumeric(G)
    tmp = G; G = chebfun;
    for k = 1:numel(G)
        G(k) = chebfun(tmp(k),F.ends([1 end]));
    end
    if F.trans, G = transpose(G); end
end    

% Check the domains
dF = F(1).ends([1 end]);
dG = G(1).ends([1 end]);
if any(dF~=dG)
    error('CHEBFUN:or:doms','Inconsistent domains.');
end

% Check the orientation
tF = F(1).trans;
tG = G(1).trans;
if tF ~= tG
    error('CHEBFUN:or:trans','Matrix dimensions must agree.');
elseif tF
    F = transpose(F);
    G = transpose(G);
end

% Check the number of columns
nF = numel(F);
nG = numel(G);
if nF ~= nG && min(nF,nG) > 1
    error('CHEBFUN:or:dims','Matrix dimensions must agree.');
elseif nF > nG
    for k = 1:nF
        H(k) = andcol(F(k),G);
    end
elseif nF < nG
    for k = 1:nF
        H(k) = andcol(F,G(k));
    end
else
    for k = 1:nF
        H(k) = andcol(F(k),G(k));
    end
end

% Transpose back to row chebfun
if tF, H = transpose(H); end

function H = andcol(F,G)
% operate on each of the columsn
H = all(horzcat(any(F,2),any(G,2)),2);

    

