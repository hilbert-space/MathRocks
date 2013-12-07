function f = volt(K,v)
%VOLT  Volterra integral operator.
%
% V = VOLT(K,f) returns a row chebfun resulting from the integral
%     
%      f(x) = (V*v)(x) = int( K(x,y) v(y), y=a..x )
%   
% The kernel function K(x,y) must be a smooth chebfun2.
%
% Example:
% 
% f = VOLT(chebfun2(@(x,y) exp(x-y)),chebfun('x'));  
% 
% See also FRED. 

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun2 information.

mode = chebfun2pref('mode'); 

if ( ~isa(K,'chebfun2') )
    error('CHEBFUN2:volt:input','First argument must be a chebfun2');
end

% integral and give back chebfun. 
func = get(K,'fun2'); 
C = func.C; R=func.R; U=func.U;

% plus up columns of C.
rect = K.corners; 


if isa(v,'function_handle')
    v = chebfun(v,rect(3:4));  % convert to a chebfun on the right interval. 
end

% check that the domain of chebfun2 and chebfun are correct. 
chebdomain = v.ends; 
if length(chebdomain) ~= 2
    error('CHEBFUN2:FRED:CHEBDOMAIN','Domain of chebfun and chebfun2 kernel do not match');
elseif all(rect(3:4) - chebdomain)
    error('CHEBFUN2:FRED:CHEBDOMAIN','Domain of chebfun and chebfun2 kernel do not match');
end

% So we have kernel with chebfun now.
if ( ~mode )
    C = chebfun(C,rect(3:4));
    R =chebfun(R.',rect(1:2)).';
end

RR = (diag(1./U)*R);
f = chebfun([0 0],rect(1:2));

% slow unvectorized way... 
for jj = length(func):-1:1
    CC = cumsum(v.*C(:,jj));
    f = f + CC.*RR(jj,:).';
end

% convert to a row chebfun because that makes sense 
if ~v.trans
    v = v.';
end


end