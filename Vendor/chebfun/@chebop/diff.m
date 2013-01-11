function [N isLin] = diff(N,u,flag)
%DIFF    Jacobian (Frechet derivative) of nonlinear operator.
% J = DIFF(N,U), for a chebop N and chebfun U, returns a chebop
% representing the Jacobian (i.e., the Frechet derivative) of N evaluated
% at U. More specifically, J is the operator such that
%
%   || N(u+delta) - N(u) - J*delta || / ||delta|| -> 0
%
% in the limit ||delta|| -> 0. If U is a quasimatrix and/or N.op(U) is a
% quasimatrix with multiple chebfun columns, then J has a block operator
% structure.
%
% Note that J includes boundary conditions, if any are specified for N.
% Each condition, given in the form g(u)=0, produces a linear boundary
% condition in J in the form g'(u)*delta. The operator g'(u) is assigned
% as a corresponding boundary condition of J.
%
% [J ISLIN] = DIFF(N,U) returns a binary vector with entries ISLIN(1) to
% ISLIN(4) showing whether N.OP, N.LBC, N.RBC, and N.BC are linear
% respectively.
%
% DIFF(N,U,'linop') returns a linop of the Jacobian (rather than a chebop),
% which is typically faster to work with than a linear chebop.
%
% Example: A basic Newton iteration to solve u''-exp(u)=0, subject to
%          u(0)=1, u(1)*u'(1)=1
%   dom = [0 1];
%   x = chebfun('x',dom);
%   u = 1-x;
%   lbc = @(u) u-1;  
%   rbc = @(u) u.*diff(u)-1;
%   N = chebop(@(u) diff(u,2)-exp(u),dom,lbc,rbc);
%   for k = 1:6
%     r = N(u);  J = diff(N,u);
%     delta = -J\r;  u = u+delta;
%   end
%   plot(u), title(sprintf('|| residual || = %.3e',norm(N(u))))
%
% Note that the recommended way of solving this nonlinear problem with
% chebops is 
%   dom = [0 1];
%   x = chebfun('x',dom);
%   lbc = @(u) u-1;  
%   rbc = @(u) u.*diff(u)-1;
%   N = chebop(@(u) diff(u,2)-exp(u),dom,lbc,rbc)
%   N = set(N,'init',1-x);
%   u = N/0;
%
% See also chebfun/diff, chebop/linop, chebop/mldivide.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

[J BC isLin] = linearise(N,u);

if nargin == 3 && strcmp(flag,'linop')
    N = J;
    return
end

N.op = J;
N.jumpinfo = J.jumpinfo;
N.domain = get(J,'domain');
if ~isempty(BC)
    N.lbc = BC.left;
    N.rbc = BC.right;
    N.bc = BC.other;
end

if ~isLin(1)
    N.opshow = [];
end

if ~all(isLin(2:4))
    N.lbcshow = [];
    N.rbcshow = [];
    N.bcshow = [];
end
