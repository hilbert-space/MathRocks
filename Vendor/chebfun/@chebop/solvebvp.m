function varargout = solvebvp(N,rhs,varargin)
%SOLVEBVP   Solve linear or nonlinear ODE BVPs (boundary-value problems).  
%
% Example:
%   N = chebop(-1,1);
%   N.op = @(u) diff(u,2) + sin(u);
%   N.lbc = 0;
%   N.rbc = 1;
%   u = solvebvp(N,0);    % equivalent to u = N\0
%   norm(N(u))            % test that ODE is satisfied
%
% There are several preferences that users can adjust to control the
% solution method used by SOLVEBVP (or \).  See CHEBOPPREF. In particular,
% one can specify
%   cheboppref('damped','off')   % pure Newton iteration
%   cheboppref('damped','on')    % damped Newton iteration (the default)
% One can also control display options during the solution process.
%
% See CHEBOPPREF, CHEBOP/MLDIVIDE.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% (Developed by Toby Driscoll and Asgeir Birkisson, 2009.)

% Initialize arguments to be passed on later
pref = []; guihandles = []; jac = [];

% Do all parsing of varargin here rather than in solve_bvp_routines
argCounter = 1;
while argCounter <= nargin-2
    arg = varargin{argCounter};
    if strcmpi(arg,'FJacobian') || strcmpi(arg,'FFrechet')
        Fjacobian = varargin{argCounter+1};
    elseif strcmpi(arg,'options')
        pref = varargin{argCounter+1};
    elseif strcmpi(arg,'guihandles')
        guihandles = varargin{argCounter+1};
    else
        error('Chebop:solvebvp',['Unknown option ' arg '.']);
    end
    argCounter = argCounter + 2;
end

% If no options are passed, obtain the the chebop preferences
if isempty(pref)
    pref = cheboppref;
end

% Before starting any attempts to solve a problem, check whether we
% actually have a nonempty .op field:
% Check operator
if isempty(N.op)
    error('CHEBOP:solvebvp:OpEmpty','Operator is empty.');
end


% We are going to treat linear and nonlinear problems separately. This
% requires us to do a linearisation check before calling individual
% routines (which are private methods).

% Need to start by determining the dimensions on chebfuns (i.e. number of
% columns in the quasimatrix) which the chebop operates on. If we N.init is
% given, we assume it's of correct dimension, otherwise, call findNumVar:
if isempty(N.init) % No initial guess given
    initPassed = 0;
    if isempty(N.domain)
        error('CHEBOP:solvebvp:noGuess','Neither domain nor initial guess is given.')
    else
        u0 = findNumVar(N); % Gives quasimatrix of zero chebfun(s)
        % Update the domain of N, using the breakpoints of what findNumVar
        % returns 
        N.domain = union(N.domain, domain(u0));
    end
else % Shouldn't expect to go in here for linear problems, as initial guess probably won't be provided 
    initPassed = 1;
    N.init = 1*N.init; % This is weird, but for some reason need. AB?
    u0 = N.init;
    % Update the domain of N, ensuring that both the breakpoints in the
    % initial guess, as well as breakpoints imposed when N was created are
    % used
    N.domain = union(N.domain, domain(u0));
end


% Now that we have a zero function (or quasimatrix), we can carry out a
% linearisation, which gives us linearity information
[A bc isLin affine] = linearise(N,u0);

% Before attempting to solve, check whether we actually have any BCs
% imposed:
maxdo = max(max(get(A,'difforder')));
if maxdo > 0 && isempty(N.lbc) && isempty(N.rbc) && isempty(N.bc)
    % Differential equations need boundary conditions (but integral eqns are OK).
    error('CHEBOP:solvebvp:BCEmpty''All BCs empty.');
end
% Also check whether we have periodic conditions, but also some other
% conditions at the endpoints of the domain, which is not possible
if any(strcmpi(N.bc,'periodic')) && (~isempty(N.lbc) || ~isempty(N.rbc))
    error('CHEBOP:solvebvp:periodic',...
        'Periodic boundary can not be imposed at the same time as other endpoint conditions.');
end

% !!! Here we want to deal with adjusting RHS to reflect affine parts

if isLin % Linear problem -- sweet!
    A = A & bc;
    [u nrmDeltaRelvec] = solvebvp_lin(A,rhs,affine,pref,guihandles);
    varargout{1} = u;
    varargout{2} = nrmDeltaRelvec;
    varargout{3} = isLin;
else % We have a nonlinear problem -- start the whole mechanism of Newton iterations
    % Start by obtaining an initial guess which satisfies linear BCs if an
    % initial guess was not passed (i.e. we are wanting to construct an
    % initial guess automatically)
    if ~initPassed
        u0 = fitBCs(A & bc);
    end
    
    [varargout{1} varargout{2} varargout{3}] = solvebvp_nonlin(N,rhs,u0,pref,guihandles);
end