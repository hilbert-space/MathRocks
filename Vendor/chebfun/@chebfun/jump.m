function j = jump(u,x,c)
% JUMP   Compute the jump in a chebfun over a breakpoint.
%
% J = JUMP(F,X) is simply a wrapper for F(X,'right')-U(F,'left')
%
% Example:
%   x = chebfun('x');
%   jump(sign(x),0)      % returns 2
% 
% See also CHEBFUN/FEVAL.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 3, c = 0; end

j = feval(u,x,'right') - feval(u,x,'left') - c;

