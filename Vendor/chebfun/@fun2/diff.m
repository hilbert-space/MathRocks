function f  = diff(f,n,dim)
% DIFF Derivative of a fun2. 
%
% DIFF(F) is the derivative of the fun2 F along the y direction. 
%
% DIFF(F,N) is the Nth derivative of F.
%
% DIFF(U,N,DIM) is the Nth difference function along dimension DIM. 
%      If N >= size(U,DIM), DIFF returns an empty chebfun.
%      DIM = 1 (default) is derivative in the y-direction. 
%      DIM = 2 is derivative in the x-direction.
%
% See also CHEBFUN2/DIFF.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

pref2 = chebfun2pref; mode=pref2.mode;

if nargin == 1, n = 1; dim = 1; end  % defaults. 
if nargin == 2, dim = 1; end         % diff in y is default. 

% zero function check. 
if norm(f.U) < eps 
    rect=getdomain(f);  f = fun2(0,rect);  return;
end


if numel(n) == 1   % integer diff.
    if( dim == 1 )
        if mode
            f.C = diff( get(f,'C'),n ); % What do we do about scl?
        else
            C = get(f,'C'); mapdy = f.map.dery(1);
            for j = 1:n
                C = chebifft(newcoeffs_der(chebfft(C))); % vectorised diff.
            end
            C = C./mapdy.^n; f.C = C; 
        end
    elseif ( dim == 2 )
        if mode 
            f.R = diff( get(f,'R'),n ); % What do we do about scl?
        else
            R = get(f,'R'); R = R.';  mapdx = f.map.derx(1);
            for j = 1:n
                R = chebifft(newcoeffs_der(chebfft(R)));
            end
            R = R./mapdx.^n;
            f.R = R.'; %tranpose back. 
        end
%     elseif ( dim == 0 ) % complex differentiation. 
%          f = 2*( diff(f,n,2) + 1i*diff(f,n) ) ;
    else
        % dim > 2
        error('FUN2:diff:dim','Derivative is not in x or y.');
    end
elseif numel(n) == 2 && nargin == 2 % diff degrees as a vector. 
    % diff n(1) in x-direction and n(2) in y-direction. 
        f = diff(diff(f,n(2)),n(1),2);
%         f.C = diff( get(f,'C'),n(2) ); % What do we do about scl?
%         f.R = diff( get(f,'R'),n(1) ); % What do we do about scl?
else
    if( nargin > 2 ) 
        error('FUN2:diff:dim','Unable to determine derivative direction');
    end
    if( numel(n) > 2)
        error('FUN2:diff:n','Derivative direction overdefined');
    end
end

end

function cout = newcoeffs_der(c)
% C is the coefficients of a chebyshev polynomials (on [-1,1])
% COUT are the coefficiets of its derivative
[n m]= size(c); cout = zeros(n+1,m);     % initialize vector {c_r}
v = zeros(n+1,m); D = spdiags((n-1:-1:1)',0,n-1,n-1);

v(3:n+1,:) = 2*D*c(1:end-1,:); % temporal vector
cout(1:2:n+1,:) = cumsum(v(1:2:n+1,:));    % compute c_{n-2}, c_{n-4},...
cout(2:2:n+1,:) = cumsum(v(2:2:n+1,:));    % compute c_{n-3}, c_{n-5},...
cout(n+1,:) = .5*cout(n+1,:);              % rectify the value for c_0
cout = cout(2:n+1,:);
end