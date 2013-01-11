function L = vertcatJac(L,varargin)
% VERTCATJAC - Vertical concatenation of jacobians
%
% VERTCATJAC(DERS{:}) is called by the jacobian info in chebfun/vertcat and 
% returns the vertically concatenated jacobians of the input chebfuns DERS.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

while ~isempty(varargin)
    A = L;
    B = varargin{1}; varargin(1) = [];

    opA = get(A,'oparray'); opB = get(B,'oparray');
    varA = get(A,'varmat'); varB = get(B,'varmat');
    op = @(u) [ opA(u) ; opB(u)];
    mat = @(n) [ varA(n) ; varB(n) ];

    domA = A.domain;  domB = B.domain;
    dom = domain(union(domA.endsandbreaks,domB.endsandbreaks));

    difforder = max(A.difforder, B.difforder);
    iszero = A.iszero && B.iszero;
    isdiag = A.isdiag && B.isdiag;

    L = linop(mat, op, dom, difforder);
    L.iszero = iszero;
    L.isdiag = isdiag;
end

end