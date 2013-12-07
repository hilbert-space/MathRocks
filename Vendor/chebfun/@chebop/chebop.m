%CHEBOP  Construct an operator on chebfuns.
% N = CHEBOP(OP) creates a chebop object N with operator defined by OP,
% which should be a handle to a function that accepts one or more chebfuns
% as input and returns a chebfun (or quasimatrix). The first input argument
% to OP is the independent variable X, while all others represent dependent
% functions of X; if only one input argument is accepted by OP, it is the
% dependent variable. Examples:
%
%   @(x,u) x.*diff(u) + u;  % one dependent variable
%   @(x,u,v,w) [ u.*diff(v), diff(u,2)+w, diff(w)-v ];  % 3 dependent vars
%   @(x,u) [ u(:,1)-diff(u(:,2)), diff(u(:,1)).*u(:,2) ];  % quasimatrix
%   @(u) diff(u,2) - exp(u);  % no explicit independent variable
%   @(u) [ diff(u(:,2))-u(:,1), diff(u(:,1)) ];  % no independent variable
%
% The number of columns in the output quasimatrix should equal the number
% of dependent variables, whether specified as names or quasimatrix
% columns. For systems of equations not given in quasimatrix form, the
% first input argument is always the independent variable.
%
% By default, the operator acts on chebfuns defined on the domain [-1,1].
% CHEBOP(OP,D), for a domain or 2-vector D, gives a different domain.
% [N X] = CHEBOP(OP,D) returns also the linear function X on the domain D.
%
% CHEBOP(OP,D,LBC,RBC) or CHEBOP(OP,LBC,RBC) specifies boundary conditions
% for functions at the left and right endpoints of the domain. Possible
% values for LBC and RBC are:
%
%   []          : No condition.
%   scalar      : All variables equal the given value.
%   'dirichlet' : All variables equal zero.
%   'neumann'   : All variables have derivative zero.
%   function    : Must accept dependent variables as given in OP and return
%                 a chebfun or quasimatrix. All columns of the result are
%                 evaluated at the endpoint and forced to equal zero.
%
% A boundary condition function may be nonlinear; it must not accept the
% independent variable X as an input. Some examples:
%
%   @(u) diff(u) - 2;            % set u' = 2
%   @(u,v,w) [ u-1, w ];         % set u=1 and w=0
%   @(u) u(:,2) - diff(u(:,2)) ; % set u_2 - (u_2)' = 0
%   @(u,v,w) u.*v - diff(w)      % set u*v=w'
%
% CHEBOP(OP,BC) or CHEBOP(OP,D,BC) gives boundary or other side conditions
% in an alternate form. Choices for BC are:
%
%   scalar      : All variables equal the given value at both endpoints.
%   'dirichlet' : All variables equal zero at both endpoints.
%   'neumann'   : All variables have derivative zero at both endpoints.
%   'periodic'  : Impose periodicity on all dependent variables.
%   function    : See below.
%
% Note that the 'dirichlet' and 'neumann' keywords impose behavior that may
% not be identical to the common understanding of Dirichlet or Neumann
% conditions in every problem.
%
% When BC is passed in the CHEBOP call, the more specialized fields LBC and
% RBC are ignored. Note that CHEBOP(OP,0) is not the same as
% CHEBOP(OP,0,[]).
%
% If BC is given a function handle, then each condition must give points
% explicitly or otherwise evaluate to a scalar
%    @(x,u) [ u(1) - u(0), sum(x.*u) ]
%
% BCs can also be assigned to the chebop N after it has been constructed,
% by N.lbc = ..., N.rbc = ..., and N.bc = ... . This will overwrite the BCs
% currently stored in the field being assigned to, but not the other
% fields).
%
% CHEBOP(OP,...,'init',U) provides a chebfun as a starting point for
% nonlinear iterations or a PDE solution. See CHEBOP/SOLVEBVP and
% CHEBOP/PDE15S for details.
%
% N = CHEBOP(..., 'dim',DIM) where DIM is an integer informs the chebop
% that it operates on quasimatrices of dimension Inf x Dim.
%
% Note that many fields can be set after the chebop object N is created:
% N.op, N.lbc, N.rbc, N.bc, N.init can all be assigned new values. For
% example:
%    N = chebop(-5,5);  % Constructs an empty chebop on the interval [-5,5]
%    N.op = @(x,u) 0.01*diff(u,2) - x.*u;
%    N.bc = 'dirichlet';
%    plot(N\1)
%
% There is some support for solving systems of equations containing unknown
% parameters without the need to introduce extra equations into the system.
% For example, y''+x.*y+p = 0, y(-1) = 1, y'(-1) = 1, y(1) = 1 can be
% solved via
%    N = chebop(@(x,y,p)diff(y,2)+x.*y+p,@(y,p)[y-1,diff(y)],@(y,p)y-1);
%    plot(N\0)
% This syntax will work whenever p is not differentiated within N.op, i.e.,
% something like @(x,y,p) diff(p*diff(y)) will require a second equation
% explicitly enforcing that diff(p) = 0.
%
% See also chebop/mtimes, chebop/mldivide, cheboppref.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


classdef (InferiorClasses = {?double}) chebop
    
    properties ( GetAccess = 'public', SetAccess = 'public' )
        domain = [];    % Domain of the operator
        op = [];        % The operator
        opshow = [];    % Pretty-print of the operator
        lbc = [];       % Left boundary condition(2)
        lbcshow = [];   % Pretty-print
        rbc = [];       % Right boundary condition(s)
        rbcshow = [];   % Pretty-print
        bc = [];        % Other/internal/mixed boundary conditions
        bcshow = [];    % Pretty-print
        init = [];      % Initial guess/conditions of nonlin probs/pdes
        numvar = [];    % % Number of indep vars in the operator
        dim = [];       % Size of the system (number of eqns)
        scale = [];     % Relative solution scale
        jumpinfo = [];  % Locations of enforced jumps in soln
    end
    
    methods
        
        function N = chebop(varargin)
            [N d] = ctor(N,varargin{:});
            N.domain = domain(d); %#ok<CPROP>
        end
        
    end
end

function [N dom] = ctor(N, varargin)

% Initialise
op = [];
dom = chebfunpref('domain');
havedomain = false;

% Return an empty chebop.
if isempty(varargin), return, end

% Find the first function_handle. This will be the op.
if isa(varargin{1},'function_handle')
    op = varargin{1};
    varargin(1) = [];
    N = set(N,'op',op);
elseif numel(varargin)>1 && isa(varargin{2},'function_handle')
    dom = varargin{1};
    op = varargin{2};
    varargin(1:2) = [];
    N = set(N,'op',op);
    havedomain = true;
end

% No op is given, we're constructing a blank chebop
if isempty(op) && ~havedomain
    if isa(varargin{1}, 'domain')
        dom = varargin{1};
    else
        dom = [];
        while ~isempty(varargin) && isnumeric(varargin{1})
            dom = [dom varargin{1}]; %#ok<AGROW>
            varargin(1) = [];
        end
    end
    return % And we're done
end

% Nothing else is given, so return
if isempty(varargin), return, end

% Is the next input (literally) a domain?
if isa(varargin{1},'domain')
    dom = varargin{1};
    varargin(1) = [];
    if isempty(varargin), return, end
end

% Look for a dim flag
if numel(varargin) > 1 && strncmpi(varargin{end-1},'dim',3)
    N.dim = varargin{end};
    varargin(end-1:end) = [];
end

% Nothing else is given, so return
if isempty(varargin), return, end

% Look for an init flag for the initial guess
if numel(varargin) > 1 && strncmpi(varargin{end-1},'init',4)
    N.init = varargin{end};
    varargin(end-1:end) = [];
elseif isa(varargin{end},'chebfun')
    N.init = varargin{end};
    varargin(end) = [];
end

% Nothing else is given, so return
if isempty(varargin), return, end

% Now HERE everything is given, so it's easy
if numel(varargin) == 3
    dom = varargin{1};
    N = set(N,'lbc',createbc(varargin{2},N.numvar));
    N.lbcshow = varargin{2};
    N = set(N,'rbc',createbc(varargin{3},N.numvar));
    N.rbcshow = varargin{3};
    return
elseif numel(varargin) == 2 && havedomain
    N = set(N,'lbc',createbc(varargin{1},N.numvar));
    N.lbcshow = varargin{1};
    N = set(N,'rbc',createbc(varargin{2},N.numvar));
    N.rbcshow = varargin{2};
    return
end

% Error
if numel(varargin) > 2
    error('CHEBOP:chebop:numinputs','Too many inputs to chebop constructor.');
end

% The only possibilities we have left are, I think, DOM, BC and LBC, RBC if
% there are still two varargins, or DOM or BC if there's only one.
% We assume the former, unless varargin{1} doesn't give a valid domain.

% Periodic is special (as it should only be set to bc, not lbc or rbc).
if numel(varargin) == 2 && strcmpi(varargin{2},'periodic')
    dom = varargin{1};
    if numel(varargin) == 2
        N = set(N,'bc',varargin{2});
    end
    return
end

% Is varargin{1} a valid domain?
if ~isnumeric(varargin{1}) || numel(varargin{1})<2 || any(sort(varargin{1})-varargin{1})
    % No
    if numel(varargin) == 1
        N = set(N,'bc',varargin{1});
    else
        N = set(N,'lbc',createbc(varargin{1},N.numvar));
        N.lbcshow = varargin{1};
        N = set(N,'rbc',createbc(varargin{2},N.numvar));
        N.rbcshow = varargin{2};
    end
    return
else
    % Yes!
    dom = varargin{1};
    if numel(varargin) == 2
        N = set(N,'bc',varargin{2});
    end
    return
end


end

