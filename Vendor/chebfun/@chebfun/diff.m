function [F nonConst] = diff(F,n,dim,RL)
% DIFF   Differentiation of a chebfun.
%
% DIFF(F) is the derivative of the chebfun F. At discontinuities, DIFF
% creates a Dirac delta with coefficient equal to the size of the jump.
% Dirac deltas already existing in F will increase their degree.
%
% DIFF(F,N) is the Nth derivative of F.
%
% DIFF(F,ALPHA) when ALPHA is not an integer offers some support for
% fractional derivatives (of degree ALPHA) of F. For ALPHA > 1 the Riemann-
% Liouville definition is used by default. On can switch to the Caputo
% definition with a call of the form DIFF(F,ALPHA,[],'Caputo').
%
% DIFF(F,U) where U is a chebfun returns the Jacobian of the chebfun F 
% with respect to the chebfun U. Either F, U, or both can be a quasimatrix.
%
% DIFF(U,N,DIM) is the Nth difference function along dimension DIM. 
%      If N >= size(U,DIM), DIFF returns an empty chebfun.
%
% See also diff

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check inputs
if nargin == 1, n = 1; end
if nargin < 3 || isempty(dim)
    dim = 1+F(1).trans; 
end
if isnumeric(dim) && ~(dim == 1 || dim == 2)
    error('CHEBFUN:diff:dim','Input DIM should take a value of 1 or 2.');
end
if nargin < 4 || isempty(RL)
    RL = 'RL';
end

if isa(n,'chebfun')     
    % AD
    if isnumeric(F)
        error('CHEBFUN:diff:scalarAD',...
            'Attempting to AD a double. Did you set the funreturn flag?')
    end
    [F nonConst] = jacobian(F,n);
    if nargin == 3, return, end
    J = chebop(F.domain);
    J.op = F; 
    if ~isempty(inputname(1)) && ~isempty(inputname(2))
        s = ['diff(' inputname(1) ',' inputname(2) ')'];
    else
        s = '';
    end
    J = set(J,'opshow',s);
    F = J;
elseif round(n)~=n      
    % Fractional derivatives
    if strcmpi(RL,'Caputo')
        F = fraccalc(diff(F,ceil(n)),ceil(n)-n); % Caputo
    else
        F = diff(fraccalc(F,ceil(n)-n),ceil(n)); % Riemann-Liouville 
    end
elseif dim == 1+F(1).trans
    % Differentiate along continuous variable
    for k = 1:numel(F)
        F(k) = diffcol(F(k),n);
    end
    
else
    % Diff along discrete dimension
    if numel(F) <= n, F = chebfun; return, end % Return empty chebfun
    if F(1).trans
        for k = 1:n
            F = F(2:end,:)-F(1:end-1,:);
        end 
    else
        for k = 1:n
            F = F(:,2:end)-F(:,1:end-1);
        end 
    end
    
end

% -------------------------------------------------------------------------
function F = diffcol(f,n)
% Differentiate column along continuous variable to an integer order 

if isempty(f) || isempty(f.funs(1).vals)
    F = chebfun; 
    return
end

tol = max(chebfunpref('eps')*10, 1e-12) ;

F = f;
funs = f.funs;
ends = get(f,'ends');
F.jacobian = anon('der1 = diff(domain(f),n); [der2 nonConst] = diff(f,u,''linop''); der = der1*der2;',{'f' 'n'},{f n},1,'diff');
F.ID = newIDnum;

for j = 1:n % Loop n times for nth derivative
    
    % Differentiate every piece and rescale
    funs = diff(funs);
    newscl = max(get(funs,'scl.v'));
    F.scl = max(F.scl,newscl);
    F.funs = funs;

    F.imps(1,:) = jumpvals(F.funs,ends);
    
    % Detect jumps in the function
    fright = f.funs(1);
    newimps = zeros(1,f.nfuns+1);
    for i = 2:f.nfuns
        fleft = fright; fright = f.funs(i);
        jmp = fright.vals(1) - fleft.vals(end);
        if abs(jmp) > tol*f.scl
           newimps(i) = jmp;
        end
    end
    
    % Update imps
    if size(F.imps,1)>1
       F.imps = [F.imps(1,:); newimps; F.imps(2:end,:)];
    elseif any(newimps)
       F.imps(2,:) = newimps;
    end
    
    f = F;

end

% Update scale in funs
F.funs = set(funs,'scl.v',F.scl);
