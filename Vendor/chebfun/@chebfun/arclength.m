function out = arclength(F,a,b)
% ARCLENGTH	compute the length of the arc defined by a chebfun.
%
% If F is a chebfun, ARCLENGTH(F) is the arc length of the curve defined by
% y = F(x) in the x-y plane over the interval where it is defined. 
% ARCLENGTH(F,A,B) is the arc length of F over the interval [A B].
%
% If F is a chebfun of complex values, ARCLENGTH(F) returns the arc length
% of the curve in the complex plane. ARCLENGTH(F,A,B) computes the length 
% of the arc whose ends correspond to A and B. 
%
% If F is a quasimatrix, the arc length of each chebfun in F will be
% computed and a vector is returned.
%
% Examples:
% f = chebfun('sin(x)',[0 1]);
% L = arclength(f);

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(F), out = 0; return, end    % empty chebfun has arclength 0
if ~isa(F,'chebfun')
    error('CHEBFUN:arclength:F','The first input argument must be a chebfun object or an array of chebfun objects.')
    return
end

subint = false;
if nargin == 3
    subint = true;
elseif nargin == 1
    % nothing to do here
elseif isa(a,'domain')
    ends = a.ends; a = ends(1); b = ends(end); subint = true;
elseif numel(dim) > 1
    a = ends(1); b = ends(end); subint = true;
end

F_trans = F(1).trans;                  % default sum along columns

if F_trans
    F = transpose(F);
end

if subint
    out = arclength_subint(F,a,b);
else
    out = arclength_entire(F);
end

if F_trans
    out = out.';
end

end

function out = arclength_entire(F)

for k = 1:size(F,2)
    fprime = diff(F(k));
    if isreal(F(k))
        out(k) = sum(sqrt(1+fprime.^2));
    else
        out(k) = sum(abs(fprime));
    end
end
end

function out = arclength_subint(F,a,b)
for k = 1:size(F,2)
    fprime = diff(F(k));
    if isreal(F(k))
        out(k) = sum(sqrt(1+fprime.^2),a,b);
    else
        out(k) = sum(abs(fprime),a,b);
    end
    
end
end