function f = fred(K,v)
%FRED  Fredholm integral operator with a chebfun2 kernel.
%  
%  F = FRED(K,V) computes the Fredholm integral with kernel K:
%     
%       (F*v)(x) = int( K(x,y)*v(y), y=c..d ),  x=a..b
%  
%  where [c d] = domain(V) and [a b c d] = domain(K). The kernel function 
%  K(x,y) should be smooth for best results. K is a chebfun2 and V is a chebfun. 
%  The result is a row chebfun object.
%
% See also VOLT.

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

mode = chebfun2pref('mode');

if( ~isa(K,'chebfun2'))
    if isa(K,'function_handle')
        K = chebfun2(K);
    else
        error('CHEBFUN2:fred:input','First argument must be a chebfun2');
    end
end


rect = K.corners; 

if isa(v,'function_handle')
   v = fun2(v,rect); cv = v.fun2.C;  v=cv(1)*(v.fun2.U)*((v.fun2.R).');
end

% check that the domain of chebfun2 and chebfun are correct. 
chebdomain = v.ends; 
if length(chebdomain) ~= 2
    error('CHEBFUN2:FRED:CHEBDOMAIN','Domain of chebfun and chebfun2 kernel do not match');
elseif all(rect(3:4) - chebdomain)
    error('CHEBFUN2:FRED:CHEBDOMAIN','Domain of chebfun and chebfun2 kernel do not match');
end


% integral and give back chebfun. 
func = get(K,'fun2'); 
C = func.C; R=func.R; U=func.U; 


if ~mode 
    C = chebfun(C,rect(3:4));
    R =chebfun(R.',rect(1:2)).';
end

C = (C.'*v).';
f = C*diag(1./U)*R;

end