function r=roots(f,varargin)
%ROOTS zero contours of a chebfun2, or common zeros of two chebfun2 objects
% 
% R = ROOTS(F), returns the zero contours of F as a quasimatrix of chebfuns. 
% Each column of R is one zero contour. This command only finds contours when
% there is a change of sign and it can also group intersecting contours in
% a non-optimal way. Contours are computed to, roughly, four digits of
% precision. In particular, this command cannot reliably compute isolated 
% real roots of F.
%
% In the special case when F is of length 1 then the zero contours are 
% found to full precision. 
%
% R = ROOTS(F,G) returns the isolated points of F and G, which are computed
% by either the marching squares or a resultant method depending on the
% properties of F and G (see CHEBFUN2V/ROOTS). The resultant method is
% considered more robust and reliable.
% 
% ROOTS(F,G,'ms') or ROOTS(F,G),'marchingsquares') computes the isolated
% common zeros by an algorithm based on marching squares. 
%
% ROOTS(F,G,'resultant') computes the isolated common zeros by a
% resultant-based method (see [1]). 
%
% [1] Y. Nakatsukasa, V. Noferini, and A. Townsend, Computing the common 
% zeros of two bivariate functions via Bezout resultants, in preparation, 
% (2013).
% 
% See also CHEBFUN2V/ROOTS.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f)
    error('CHEBFUN2:ROOTS:INPUT','The chebfun2 is an empty object');
end


if ( nargin == 1 )
mode = chebfun2pref('mode'); tol = 1e-5; % go for 5 digits of accuracy with zero contours. 

rect = f.corners; xdom = rect(1:2); ydom=rect(3:4);
r = [];
if ( length(f) == 1 )
    fun = get(f,'fun2'); r = chebfun;
    if ( mode )
        yrts = roots(fun.C); xrts = roots(fun.R);
    else
        yrts = roots(chebfun(fun.C,ydom)); xrts = roots(chebfun(fun.R.',xdom));
    end
    for jj = 1:length(yrts)
        if yrts(jj) == 0, yrts(jj) = eps; end % make sure result chebfun is complex-valued.
        r = [ r chebfun(@(x) x+1i*yrts(jj))];
    end
    for jj = 1:length(xrts)
        if xrts(jj) == 0, xrts(jj) = eps; end % make sure result chebfun is complex-valued.
        r = [ r chebfun(@(y) xrts(jj)+1i*y)];
    end
else
    if isreal(f) 
        % Use Matlab's contourc function.
        n = 2049; % disc size.
        x = linspace(rect(1),rect(2),n); y = linspace(rect(3),rect(4),n);
        [xx yy]=meshgrid(x,y); vf = feval(f,xx,yy);
        C = contourc(x,y,vf,0*[1 1]);
        j = 1; r = chebfun();
        while ( j < length(C) )
            k = j + C(2,j);  D = C(:,j+1:k);
            f = chebfun(D(1,:)+1i*(D(2,:)+eps));  % construct zero contour, make it complex.
            f = simplify(f,tol);
            j = k + 1; r = [ r , f ];
        end
    else
        % complex valued; 
        r = roots([real(f);imag(f)]);
        % make them complex again.
        if ~isempty(r)
            r = r(:,1) + 1i*r(:,2);
        end
    end
end
elseif ( isa(varargin{1},'chebfun2') )
   if ( isempty(varargin{1}) )
       warning('CHEBFUN2:ROOTS:EMPTY','Second chebfun2 is empty. Computing zero contours.')
       r = roots(f);
   end
   r = roots(chebfun2v(f,varargin{1}),varargin{2:end});  % change back to roots later.
end
    
end