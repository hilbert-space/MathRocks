function varargout=svd(f)
%SVD of a chebfun2.  
%
% SVD(F) returns the singular values of F. The number of singular values
% returned is equal to the rank of the chebfun2. 
%
% S = SVD(F) returns the singular values of F. S is a vector of singular
% values in decreasing order. 
% 
% [U S V] = SVD(F) returns the SVD of F. U and V are quasi-matrices of 
% orthogonal chebfuns and S is a diagonal matrix with the singular values
% on the diagonal.
%
% The length and rank of a chebfun2 are slightly different quantities. 
% LENGTH(F) is the number of pivots used by the Chebfun2 constructor, and 
% RANK(F) is the number of significant singular values of F. The relation 
% RANK(F) <= LENGTH(F) should always hold. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = f.fun2; pref2=chebfun2pref; rect = f.corners; 

if isempty(F) % check for empty chebfun2. 
    varargout = {[],[],[]};
    return; 
end


C = F.C; U = F.U; R=F.R;

% If the function is the zero function then special care is required. 
if ( norm(U) == 0 )
    if ( nargout > 1 )
        rect = f.corners; 
        identx = chebfun2(1./sqrt(diff(rect(2)-rect(1))),rect(1:2)); % make sure they integral to 1 in 2-norm. 
        identy = chebfun2(1./sqrt(diff(rect(4)-rect(3))),rect(3:4)); % make sure they integral to 1 in 2-norm.
        varargout = {identx, 0, identy}; 
    else
        varargout={0};
    end
    return 
end

% If the function is non-zero then do the standard stuff. 
% C = C*diag(1./U);
C = chebfun(C,rect(3:4)); R =  chebfun(R.',rect(1:2)).';
[Qc Rc] = qr(C,0); [Qr Rr] = qr(R.',0);
RR = Rc*diag(1./U)*Rr.';

% Output just like the svd of a matrix. 
if ( nargout > 1 )
    [U S V] = svd(RR);
    U = Qc*U; V = Qr*V;
    if ( pref2.mode )
        varargout = {real(U),S,real(V)};
    else
%         U = chebfun(U,[rect(3),rect(4)]); V = chebfun(V,[rect(1),rect(2)]);
        varargout = {real(U),S,real(V)};
    end
else
    S = svd(RR);
    varargout = {S};
end

end