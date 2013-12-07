function varargout = pde15s( pdefun, tt, u0, bc, varargin)
% PDE15S  Solve PDEs using the chebfun system.
%
% UU = PDE15s(PDEFUN, TT, U0, BC) where PDEFUN is a handle to a function 
% with arguments u, t, x, and D, TT is a vector, U0 is a chebfun, and BC is 
% a chebop boundary condition structure will solve the PDE 
% dUdt = PDEFUN(UU,t,x) with the initial condition U0 and boundary 
% conditions BC over the time interval TT. 
%
% PDEFUN should take the form @(U1,U2,...,UN,T,X,D,S,C), where U1,...,UN
% are the unknown dependent variables to be solved for, T is time, X is
% space, D is the differential operator, S is the definite integral
% operator (i.e., 'sum'), and C the indefinite integral operator (i.e.,
% 'cumsum').
%
% For equations of one variable, UU is output as a quasimatrix, where UU(:,k)
% is the solution at TT(k). For systems, the solution is returned as a
% cell array of quasimatrices.
%
% Example 1: Nonuniform advection
%   x = chebfun('x',[-1 1]);
%   u = exp(3*sin(pi*x));
%   f = @(u,t,x,diff) -(1+0.6*sin(pi*x)).*diff(u);
%   uu = pde15s(f,0:.05:3,u,'periodic');
%   surf(u,0:.05:3)
%
% Example 2: Kuramoto-Sivashinsky
%   d = domain(-1,1);
%   x = chebfun('x');
%   I = eye(d); D = diff(d);
%   u = 1 + 0.5*exp(-40*x.^2);
%   bc.left = struct('op',{I,D},'val',{1,2});
%   bc.right = struct('op',{I,D},'val',{1,2});
%   f = @(u,diff) u.*diff(u)-diff(u,2)-0.006*diff(u,4);
%   uu = pde15s(f,0:.01:.5,u,bc);
%   surf(u,0:.01:.5)
% 
% Example 3: Chemical reaction (system)
%    x = chebfun('x',[-1 1]);  
%    u = [ 1-erf(10*(x+0.7)) , 1 + erf(10*(x-0.7)) , 0 ];
%    f = @(u,v,w,diff)  [ .1*diff(u,2) - 100*u.*v , ...
%                         .2*diff(v,2) - 100*u.*v , ...
%                         .001*diff(w,2) + 2*100*u.*v ];
%    bc = 'neumann';     
%    uu = pde15s(f,0:.1:3,u,bc);
%    mesh(uu{3})
%
% See chebfun/examples/pde15s_demos.m and chebfun/examples/pde_systems.m
% for more examples.
%
% UU = PDE15s(PDEFUN, TT, U0, BC, OPTS) will use nondefault options as
% defined by the structure returned from OPTS = PDESET.
%
% UU = PDE15s(PDEFUN, TT, U0, BC, OPTS, N) will not adapt the grid size
% in space. Alternatively OPTS.N can be set to the desired size.
%
% [TT UU] = PDE15s(...) returns also the time chunks TT.
%
% There is some support for nonlinear and time-de[pendent boundary 
% conditions, such as
%    BC.LEFT = @(u,t,x,diff) diff(u) + u.^2 - (1+2*sin(10*t));
%    BC.RIGHT = struct( 'op', 'dirichlet', 'val', @(t) .1*sin(t));
% with the input format being the same as PDEFUN described above.
%
% See also PDESET, ODE15S, CHEBOP/PDE15S.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

global ORDER QUASIN GLOBX
ORDER = 0; % Initialise to zero
QUASIN = true;
GLOBX = [];

if nargin < 4 
    error('CHEBFUN:pde15s:argin','pde15s requires a minimum of 4 inputs.');
end

% Default options
tol = 1e-6;             % 'eps' in chebfun terminology
doplot = 1;             % plot after every time chunk?
dohold = 0;             % hold plot?
plotopts = '-';         % Plot Style
J = [];                 % Supply Jacobian
dojac = false;          % Use AD to compute Jacobian? 
dojacbc = false;        % Use AD to figure out BC rows.
getorder = true;        % Use AD to get the ORDER

% Parse the variable inputs
if numel(varargin) == 2
    opt = varargin{1};     opt.N = varargin{2};
elseif numel(varargin) == 1
    if isstruct(varargin{1})
        opt = varargin{1};
    else
        opt = pdeset;      opt.N = varargin{1};
    end
else
    opt = pdeset;
end
optN = opt.N;
if isempty(optN), optN = NaN; end
    
% PDE solver options
if ~isempty(opt.Eps), tol = opt.Eps; end
if ~isempty(opt.Plot), doplot = strcmpi(opt.Plot,'on'); end
if ~isempty(opt.HoldPlot), dohold = strcmpi(opt.HoldPlot,'on'); end
if ~isempty(opt.PlotStyle), plotopts = opt.PlotStyle; end
if ~isempty(opt.Jacobian) && ischar(opt.Jacobian)
    if strcmpi(opt.Jacobian,'auto'), dojac = 1;
    elseif strcmpi(opt.Jacobian,'none'), dojac = 0; end
    opt.Jacobian = [];
end

% Experimental feature for coupled ode/pde systems
if isfield(opt,'PDEflag')
    pdeflag = opt.PDEflag;
else
    pdeflag = true; 
end
        
% Determine which figure to plot to (for CHEBGUI)
% and set default display values for variables.
YLim = opt.YLim;
gridon = 0;
guiflag = false;
if isfield(opt,'handles')
    if opt.handles.gui
        guiflag = true;
        axesSol = opt.handles.fig_sol;
        axesNorm = opt.handles.fig_norm;
        axes(axesSol);
        gridon = opt.handles.guifile.options.grid;
        solveButton = opt.handles.button_solve;
        clearButton = opt.handles.button_clear;
    end
    varnames = opt.handles.varnames;
    xLabel = opt.handles.indVarName{1};
    tlabel = opt.handles.indVarName{2};
else
    varnames = 'u';
    xLabel = 'x';
    tlabel = 't';
end

% Parse plotting options
indx = strfind(plotopts,',');
tmpopts = cell(numel(indx)+1,1);
k = 0; j = 1;
while k < numel(plotopts)
    k = k+1;
    sk = plotopts(k);
    if strcmp(sk,',')
        tmpopts{j} = plotopts(1:k-1);
        plotopts(1:k) = [];
        j = j+1;
        k = 0;
    end
end
tmpopts{j} = plotopts;
plotopts = tmpopts;
for k = 1:numel(plotopts)
    if strcmpi(plotopts{k},'linewidth') || strcmpi(plotopts{k},'MarkerSize')
        plotopts{k+1} = str2double(plotopts{k+1});
    end
end

% ODE tolerances
% (AbsTol and RelTol must be <= Tol/10)
atol = odeget(opt,'AbsTol',tol/10);
rtol = odeget(opt,'RelTol',tol/10);
if isnan(optN)
    atol = min(atol, tol/10);
    rtol = min(rtol, tol/10);
end
opt.AbsTol = atol; opt.RelTol = rtol;

% Check for (and try to remove) piecewise initial conditions
u0trans = get(u0,'trans');
% Get u0trans as a cell if u0 is a quasimatrx
if numel(u0trans) > 1, u0trans = u0trans{1}; end
if u0trans, u0 = transpose(u0); end
for k = 1:numel(u0)
    if u0(k).nfuns > 1
        u0(k) = merge(u0(k),'all',1025,tol);
        if u0(k).nfuns > 1
            error('CHEBFUN:pde15s:piecewise',...
                'piecewise initial conditions are not supported'); 
        end
    end
end
% Simplify initial condition to tolerance or fixed size in optN
if isnan(optN)
    u0 = simplify(u0,tol);
else
    for k = 1:numel(u0)
        u0(k).funs(1) = prolong(u0(k).funs(1),optN);
    end
end

% Get the domain and the independent variable 'x'
d = domain(u0);
xd = chebfun(@(x) x,d);

% These are used often.
Z = zeros(d);
I = eye(d);
D = diff(d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% parse inputs to pdefun %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determining the behaviour of the inputs to pdefun, i.e. is it of
% quasimatrix-type, or pdefun(u,v,w,t,x,@diff) etc. (QUASIN TRUE/FALSE).
% and how many operators are there? (@diff, @sum, @cumsum, etc).
syssize = min(size(u0));            % Determine the size of the system
pdefun = parsefun(pdefun,syssize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% parse boundary conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some error checking on the bcs
if ischar(bc) && (strcmpi(bc,'neumann') || strcmpi(bc,'dirichlet'))
    if ORDER > 2
        error('CHEBFUN:pde15s:bcs',['Cannot assign "', bc, '" boundary conditions to a ', ...
        'RHS with differential order ', int2str(ORDER),'.']);
    end
    bc = struct( 'left', bc, 'right', bc);
elseif iscell(bc) && numel(bc) == 2
    bc = struct( 'left', bc{1}, 'right', bc{2});
end

% Shorthand bcs - all neumann or all dirichlet
if isfield(bc,'left') && (ischar(bc.left) || (iscell(bc.left) && ischar(bc.left{1})))
    if iscell(bc.left), v = bc.left{2}; bc.left = bc.left{1}; else v = 0; end
    if strcmpi(bc.left,'dirichlet'),    A = I;
    elseif strcmpi(bc.left,'neumann'),  A = D;
    end
    op = cell(1,syssize);
    for k = 1:syssize,   op{k} = [repmat(Z,1,k-1) A repmat(Z,1,syssize-k)];  end
    bc.left = struct('op',op,'val',repmat({v},1,syssize));
end
if isfield(bc,'right') && (ischar(bc.right) || (iscell(bc.right) && ischar(bc.right{1})))
    if iscell(bc.right), v = bc.right{2}; bc.right = bc.right{1}; else v = 0; end
    if strcmpi(bc.right,'dirichlet'),    A = I;
    elseif strcmpi(bc.right,'neumann'),  A = D;
    end
    op = cell(1,syssize);
    for k = 1:syssize,   op{k} = [repmat(Z,1,k-1) A repmat(Z,1,syssize-k)];  end
    bc.right = struct('op',op,'val',repmat({v},1,syssize));
end

if isfield(bc,'left') && ~isfield(bc,'right'), bc.right = [];
elseif isfield(bc,'right') && ~isfield(bc,'left'), bc.left = []; end

% Sort out left boundary conditions
nllbc = []; nlbcs = {}; GLOBX = 1; funflagl = false; rhs = {};
% 1) Deal with the case where bc is a function handle vector
if isfield(bc,'left') && numel(bc.left) == 1 && isa(bc.left,'function_handle')
    op = parsefun(bc.left,syssize);
    sop = size(op(ones(1,syssize),0,mean(d.ends)));   
    nllbc = 1:max(sop);    
    bc.left = struct( 'op', [], 'val', []); 
    % Dummy entries (Worked out naively. AD information may be used below).
    for k = nllbc 
        if syssize == 1
            bc.left(k).op = repmat(I,1,syssize);
        else
            bc.left(k).op = [repmat(Z,1,k-1) I repmat(Z,1,syssize-k)];
        end  
        bc.left(k).val = 0;
    end
    rhs = num2cell(zeros(1,max(sop)));
    nlbcsl = op;
    funflagl = true;
% 2) Deal with other forms of input
elseif isfield(bc,'left') && numel(bc.left) > 0
    if isa(bc.left,'linop') || iscell(bc.left)
        bc.left = struct( 'op', bc.left);
    elseif isnumeric(bc.left)
        bc.left = struct( 'op', I, 'val', bc.left); 
    end
    % Extract nonlinear conditions
    rhs = cell(numel(bc.left),1);
    for k = 1:numel(bc.left)
        opk = bc.left(k).op; 
        rhs{k} = 0;
        
        % Numerical values
        if isnumeric(opk) && syssize == 1
            bc.left(k).op = repmat(I,1,syssize);
            bc.left(k).val = opk;
        end       
        
        % Function handles
        if isa(opk,'function_handle')
            nllbc = [nllbc k];             % Store positions
            nlbcs = [nlbcs {parsefun(opk)}];
            % Dummy entries (Worked out naively. AD information may be used below).
            bc.left(k).op = [repmat(Z,1,k-1) I repmat(Z,1,syssize-k)];
        end
        
        % Remove 'vals' from bc and construct cell of rhs entries
        if isfield(bc.left(k),'val') && ~isempty(bc.left(k).val)
            rhs{k} = bc.left(k).val;
        end
        bc.left(k).val = 0;  % remove function handles
    end     
end

% Sort out right boundary conditions
nlrbc = []; numlbc = numel(rhs); funflagr = false;
% 1) Deal with the case where bc is a function handle vector
if isfield(bc,'right') && numel(bc.right) == 1 && isa(bc.right,'function_handle')
    op = parsefun(bc.right,syssize);
    sop = size(op(ones(1,syssize),0,mean(d.ends)));    
    nlrbc = 1:max(sop);
    bc.right = struct( 'op', [], 'val', []); 
    % Dummy entries (Worked out naively. AD information may be used below).
    for k = nlrbc 
        if syssize == 1
            bc.right(k).op = repmat(I,1,syssize);
        else
            bc.right(k).op = [repmat(Z,1,k-1) I repmat(Z,1,syssize-k)];
        end
        bc.right(k).val = 0;
    end
    rhs = [rhs num2cell(zeros(1,max(sop)))];
    nlbcsr = op;
    funflagr = true;
% 2) Deal with other forms of input
elseif isfield(bc,'right') && numel(bc.right) > 0
    if isa(bc.right,'linop') || isa(bc.right,'cell')
        bc.right = struct( 'op', bc.right, 'val', 0);
    elseif isnumeric(bc.right)
        bc.right = struct( 'op', I, 'val', bc.right);         
    end
    for k = 1:numel(bc.right)
        opk = bc.right(k).op; 
        rhs{numlbc+k} = 0;
        if isnumeric(opk) && syssize == 1
            bc.right(k).op = I;
            bc.right(k).val = opk;
        end
        if isa(opk,'function_handle')
            nlrbc = [nlrbc k];
            nlbcs = [nlbcs {parsefun(opk)}];
            % Dummy entries (Worked out naively. AD information may be used below).            
            bc.right(k).op = [repmat(Z,1,k-1) I repmat(Z,1,syssize-k)];
        end
        if isfield(bc.right(k),'val') && ~isempty(bc.right(k).val)
            rhs{numlbc+k} = bc.right(k).val;
        end
        bc.right(k).val = 0;
    end          
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Compute Jacobians %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = tt(1);
if dojac || getorder % This only really makes sense if the rhs is linear...
    Fu0 = pdefun(u0,t0,xd);
    Jac = diff(Fu0,u0); J = [];
    
    if getorder
        ORDER = max(max(max(Jac.op.difforder)),ORDER);
    end
%     udep = any(any(isnan(feval(diff(pdefun(utmp+NaN,tt(1),xd),utmp+NaN),9))))
%     tdep = any(any(isnan(feval(diff(pdefun(utmp,NaN,xd),utmp),9))))
end

if dojac || dojacbc
    JacL = []; JL = []; JacR = []; JR = [];
    if funflagl
        uL = nlbcsl(u0,t0,xd);
        JacL = diff(uL,u0,'linop');
        JacL = JacL.op;
        if syssize > 1
            isz = JacL.iszero;
            for j = 1:size(isz,1)
                tmpp = [];
                for k = 1:size(isz,2);
                    if ~isz(j,k),  tmpp = [tmpp I];
                    else           tmpp = [tmpp Z];
                    end
                end
                bc.left(j).op = tmpp;
            end
        else
            bc.left(1).op = JacL(1,:);
        end
            
    end
    if funflagr
        uR = nlbcsr(u0,t0,xd);
        JacR = diff(uR,u0,'linop');
        JacR = JacR.op;
        if syssize > 1
            isz = JacR.iszero;
            for j = 1:size(isz,1)
                tmpp = [];
                for k = 1:size(isz,2);
                    if ~isz(j,k), tmpp = [tmpp I];
                    else          tmpp = [tmpp Z];
                    end
                end
                bc.right(j).op = tmpp;
            end
        else
            bc.right(1).op = JacR(end,:);
        end
        
    end
end

% Support for user-defined mass matrices and coupled BVP-PDEs!
if ~isempty(opt.Mass) || ~all(pdeflag)
    usermass = true; userM = [];
    if ~all(pdeflag)
        for k = 1:numel(pdeflag)
            if pdeflag(k), A = I; else A = Z; end
            userM = [userM ; repmat(Z,1,k-1) A repmat(Z,1,syssize-k)];
        end
    end    
    if isa(opt.Mass,'chebop')
        if isempty(userM)
            userM = opt.Mass;
        else
            userM = userM*opt.Mass;
        end
    end
    
    if isempty(userM)
        error('CHEBFUN:pde15s:Mass','Mass matrix must be a chebop.');
    end
else
    usermass = false; 
end

% This is needed inside the nested function onestep()
diffop = diff(d,ORDER);
if syssize > 1
    diffop = repmat(diffop,syssize,syssize);
end


% The vertical scale of the intial condition
vscl = u0.scl;

% Plotting setup
if doplot
    if ~guiflag
        cla, shg
    end
    set(gcf,'doublebuf','on');
    if isempty(get(u0(:,1),'imps'))
        for k = 1:numel(u0); u0(:,k) = set(u0(:,k),'imps',get(u0(:,k),'ends')); end
    end
    plot(u0,plotopts{:});
    if dohold, ish = ishold; hold on, end
    if ~isempty(YLim), ylim(YLim);    end
    % Axis labels
    xlabel(xLabel);
    if numel(varnames) > 1
        legend(varnames);
    else
        ylabel(varnames);
    end
    % Determines whether grid is on
    if gridon, grid on, end
    drawnow
end

% initial condition
ucur = u0;
% storage
if syssize == 1
    uu(1) = ucur;
else
    % for systems, each functions is stored as a quasimatrix in a cell array
    uu = cell(1,syssize);
    for k = 1:syssize
        tmp(1) = ucur(k);
        uu{k} = tmp;
    end
end

% initialise variables for onestep()
B = []; q = []; rows = []; M = []; n = [];

% Set the preferences
pref = chebfunpref;
pref.eps = tol; pref.resampling = 1; pref.splitting = 0; 
pref.sampletest = 0; pref.blowup = 0; pref.vectorcheck = 0;

try
    % Begin time chunks
    for nt = 1:length(tt)-1

        % size of current length
        curlen = 0;
        for k = 1:syssize, curlen = max(curlen,length(ucur(k))); end

        % solve one chunk
        if isnan(optN)
            pref.minsamples = curlen;
            chebfun( @(x) vscl+onestep(x), d, pref);
        else
            % non-adaptive in space
            onestep(chebpts(optN,d));
        end

        % get chebfun of solution from this time chunk
        for k = 1:syssize, ucur(k) = chebfun(unew(:,k),d); end

        if isnan(optN) 
            ucur = simplify(ucur,tol);
        end

        % store in uu
        if syssize == 1,  
            uu(nt+1) = ucur;
        else
            for k = 1:syssize
                uu{k}(nt+1) = ucur(k);           
            end
        end

        % plotting
        if doplot
            plot(ucur,plotopts{:});
            if ~isempty(YLim), ylim(YLim); end
            if ~dohold, hold off, end
            % Axis labels
            xlabel(xLabel);
            if numel(varnames) > 1
                legend(varnames);
            else
                ylabel(varnames);
            end
            % Determines whether grid is on
            if gridon, grid on, end
            title(sprintf('%s = %.3f,  len = %i',tlabel,tt(nt+1),curlen)), drawnow
        elseif guiflag
            drawnow
        end

        if guiflag
            % Interupt comutation if stop or pause  button is pressed in the GUI.
            if strcmp(get(solveButton,'String'),'Solve')
                tt = tt(1:nt+1);
                if syssize == 1,  
                    uu = uu(1:nt+1);
                else
                    for k = 1:syssize
                        uu{k} = uu{k}(1:nt+1);
                    end
                end
                break
            elseif strcmp(get(clearButton,'String'),'Continue')
                defaultlinewidth = 2;
                axes(axesNorm)
                if ~iscell(uu)
                    waterfall(uu(1:nt+1),tt(1:nt+1),'simple','linewidth',defaultlinewidth)
                    xlabel(xLabel), ylabel(tlabel), zlabel(varnames)
                else
                    cols = get(0,'DefaultAxesColorOrder');
                    for k = 1:numel(uu)
                        plot(0,NaN,'linewidth',defaultlinewidth,'color',cols(k,:)), hold on
                    end
                    legend(varnames);
                    for k = 1:numel(uu)
                        waterfall(uu{k},tt(1:nt+1),'simple','linewidth',defaultlinewidth,'edgecolor',cols(k,:)), hold on
                        xlabel(xLabel), ylabel(tlabel)
                    end
                    view([322.5 30]), box off, grid on, hold off
                end
                axes(axesSol)
                waitfor(clearButton, 'String');
            end
        end
    end

catch ME % Fail gracefully.
%     ME.stack = ME.stack(1:end);
    rethrow(ME)
end

if doplot && dohold && ~ish, hold off, end

switch nargout
    case 0
    case 1        
        varargout{1} = uu;
    case 2
        varargout{1} = tt;
        varargout{2} = uu;
    otherwise
        error('CHEBFUN:pde15s:output','pde15s may only have a maximum of two outputs');
end

clear global ORDER
clear global QUASIN
clear global GLOBX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    ONESTEP   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constructs the result of one time chunk at fixed discretization
    function U = onestep(x)
%         global GLOBX

        if length(x) == 2, U = [0;0]; return, end      
        
        % Evaluate the chebfun at discrete points
        U0 = feval(ucur,x);

        % This depends only on the size of n. If this is the same, reuse
        if isempty(n) || n ~= length(x)
            n = length(x);  % the new discretisation length
            
            GLOBX = x;      % set the global variable x
            
            % See what the boundary replacement actions will be.
            [ignored,B,q,rows] = feval( diffop & bc, n, 'oldschool');

            % Mass matrix is I except for algebraic rows for the BCs.
            M = speye(syssize*n);    M(rows,:) = 0;
        
            % Multiply by user-defined mass matrix
            if usermass, M = feval(userM,n)*M; end
            
%             % Jacobians
            if dojac, J = makejac; end
%             if dojac, J = makejac2(ucur,tt(nt),n,B,rows,xd); end
        end
        
        % ODE options (mass matrix)
        opt2 = odeset(opt,'Mass',M,'MassSingular','yes','InitialSlope',odefun(tt(nt),U0),'MStateDependence','none');
        % ODE options (Jacobian)
        if dojac
            opt2 = odeset(opt2,'Jacobian',J);
        end
        
        % Solve ODE over time chunk with ode15s
        [ignored,U] = ode15s(@odefun,tt(nt:nt+1),U0,opt2);
        
        % Reshape solution
        U = reshape(U(end,:).',n,syssize);
        
        % The solution we'll take out and store
        unew = U;
        
        % Collapse systems to single chebfun for constructor (is addition right?)
        U = sum(U,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    ODEFUN   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This is what ode15s calls.
        function F = odefun(t,U)
            % Reshape to n by syssize
            U = reshape(U,n,syssize);
            
            % Evaluate the PDEFUN
            F = pdefun(U,t,x);
            
            % Get the algebraic right-hand sides (may be time-dependent)
            for l = 1:numel(rhs)
                if isa(rhs{l},'function_handle')
                    q(l,1) = feval(rhs{l},t);
                else
                    q(l,1) = rhs{l};
                end
            end

            % replacements for the BC algebraic conditions           
            F(rows) = B*U(:)-q; 
            
            % replacements for the nonlinear BC conditions
            indx = 1:length(nllbc);
            if funflagl    
                tmp = feval(nlbcsl,U,t,x);
                if ~(size(tmp,1) == n)
                    tmp = reshape(tmp,n,numel(tmp)/n);
                end
                F(rows(indx)) = tmp(1,:);
            else
                j = 0;
                for kk = 1:length(nllbc)
                    j = j + 1;
                    tmp = feval(nlbcs{j},U,t,x);
                    F(rows(kk)) = tmp(1)-q(kk);
                end
            end
            indx = numel(rhs)+1-nlrbc;
            if funflagr
                tmp = feval(nlbcsr,U,t,x);
                if ~(size(tmp,1) == n)
                    tmp = reshape(tmp,n,numel(tmp)/n);
                end
                F(rows(indx)) = fliplr(tmp(end,:));                
            else
                for kk = numel(rhs)+1-nlrbc
                    j = j + 1;
                    tmp = feval(nlbcs{j},U,t,x);
                    F(rows(kk)) = tmp(end)-q(kk);
                end
            end

            % Reshape to single column
            F = F(:);
            
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   MAKEJAC   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function J = makejac
        J = feval(Jac,n);
        J(rows,:) = B;
        % Replacements for the nonlinear BC conditions
        if funflagl    
            indx = rows(1:length(nllbc));
            JL = feval(JacL,n,'oldschool');
            J(indx,:) = JL(indx,:);
        end
        if funflagr
            indx = rows((length(nllbc)+1):end);                
            JR = feval(JacR,n,'oldschool');
            J(indx,:) = JR(indx,:);
        end
    end

    function J = makejac2(u,t,n,B,rows,xd)
        Fu = pdefun(u,t,xd);
        J = feval(diff(Fu,u,'linop'),n,'oldschool');
        J(rows,:) = B;
        if funflagl
            indx = rows(1:length(nllbc));
            JacL = diff(nlbcsl(u,t,xd),u); 
            JL = feval(JacL,n,'oldschool');
            J(indx,:) = JL(indx,:);
        end
        if funflagr
            indx = rows((length(nllbc)+1):end);
            JacR = diff(nlbcsr(u,t,xd),u);
            JR = feval(JacR,n,'oldschool');
            J(indx,:) = JR(indx,:);                
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   DIFF   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% The differential operators
function up = Diff(u,k)
    % Computes the k-th derivative of u using Chebyshev differentiation
    % matrices defined by barymat.
       
    global GLOBX ORDER QUASIN

    if nargin == 0
        error('CHEBFUN:pde15s:Diff:nargin','No input arguments recieved in Diff.');
    end
    % Assume first-order derivative
    if nargin == 1, k = 1; end
    
    if isa(u,'chebfun'), up = diff(u,k); return, end

    % For finding the order of the RHS
    if any(isnan(u)) 
        if isempty(ORDER), ORDER = k;
        else ORDER = max(ORDER,k); end
        if size(u,2) > 1, QUASIN = false; end
        up = u;
        return
    end

    N = length(u);
    x = GLOBX;
    c = 2/diff(x([1 end])); % Interval scaling
    Dk = diffmat(N,k);

    % Find the derivative by muliplying by the kth-order differentiation matrix
    up = c^k*(Dk*u);
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   SUM   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% The differential operators
function I = Sum(u,a,b)
    % Computes the integral of u using clenshaw-curtis nodes and weights
    % (which are stored for speed).

    global GLOBX QUASIN
    persistent W
    if isempty(W), W = {};    end
    
    if nargin == 0
        error('CHEBFUN:pde15s:Sum:nargin','No input arguments recieved in Sum.');
    end
    
    if isa(u,'chebfun'), 
        if nargin == 1
            I = sum(u); 
        else
            I = sum(u,a,b);
        end
        return
    end

    % For finding the order of the RHS
    if any(isnan(u)) 
        if size(u,2) > 1, QUASIN = false; end
        I = u;
        return
    end
    
    N = length(u);
    
    % Deal with the 3 args case. This can be integrating a sub-domain or
    % indefinite integration. (Or integrating the whole domain...)
    if nargin == 3
        x = GLOBX;
        if length(b) > 1
            if ~all(b==x)
                error('CHEBFUN:pde15s:sumb', ...
                    'Limits in sum must be scalars or the indep space var (typically ''x'').');
            elseif a < x(1)
                error('CHEBFUN:pde15s:sumint', 'Limits of integration outside of domain.');
            end
            
            I = Cumsum(u);
            I = I - bary(a,I,x);
            return
        elseif length(a) > 1
            if ~all(a==x)
                error('CHEBFUN:pde15s:suma', ...
                    'Limits in sum must be scalars or the indep space var (typically ''x'').');
            elseif b > x(end)
                error('CHEBFUN:pde15s:sumint', 'Limits of integration outside of domain.');
            end
            I = Cumsum(u);
            I = bary(b,I,x) - I;
            return
        elseif a ~= x(1) || b ~= x(end)
            if a < x(1) || b > x(end)
                error('CHEBFUN:pde15s:sumint', 'Limits of integration outside of domain.');
            end
            I = Cumsum(u);
            I = bary(b,I,x) - bary(a,I,x);
            return
        end
    end

    % Retrieve or compute weights.
    if N > 5 && numel(W) >= N && ~isempty(W{N})
        % Weights are already in storage
    else
        x = GLOBX;
        c = diff(x([1 end]))/2;
        W{N} = c*weights2(N);
    end

    % Find the sum by muliplying by the weights vector
    I = W{N}*u;
end 

function w = weights2(n) % 2nd kind
    % Jörg Waldvogel, "Fast construction of the Fejér and Clenshaw-Curtis 
    % quadrature rules", BIT Numerical Mathematics 43 (1), p. 001-018 (2004).
    if n == 1
         w = 2;
    else
        m = n-1;  
        c = zeros(1,n);
        c(1:2:n) = 2./[1 1-(2:2:m).^2 ]; 
        f = real(ifft([c(1:n) c(m:-1:2)]));
        w = [f(1) 2*f(2:m) f(n)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   CUMSUM   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% The differential operators
function U = Cumsum(u)
    % Computes the indefinite integral of u.

    global GLOBX QUASIN

    if nargin == 0
        error('CHEBFUN:pde15s:Cumsum:nargin','No input arguments recieved in Cumsum.');
    end
    
    if isa(u,'chebfun'), U = cumsum(u); return, end

    % For finding the order of the RHS
    if any(isnan(u)) 
        if size(u,2) > 1, QUASIN = false; end
        U = u;
        return
    end

    N = length(u);
    if N == 1, U = u; return, end
    
    % Compute matrix.
    x = GLOBX;
    c = diff(x([1 end]))/2;
    C = cumsummat(N);

    % Find the indefinite integral by muliplying cumsum matrix
    U = c*(C*u);
end 

function outfun = parsefun(infun,syssize)
global QUASIN
Nin = nargin(infun);
tmp = NaN(1,syssize);
% Number of operators, (i.e. diff, sum, cumsum) present in infun
% Also computes QUASIN through global variable in Diff.
k = 1; Nops = [];
opslist = {@Diff,@Sum,@Cumsum};
while k < 4 && isempty(Nops)
    tmp2 = repmat({tmp},1,nargin(infun)-(k+1));
    try
        ops = opslist(1:k);
        infun(tmp,tmp2{:},ops{:});
        Nops = k;
    catch ME
        %
    end
    k = k+1;
end


% Check for 'sum' and 'cumsum' in string, in case the above failed
% (which can happen if 'diff' is not present). This is a last resort, 
% and won't work if the function is, say, an mfile.
if isempty(Nops)
    funstr = func2str(infun); funstrl = lower(funstr);
    if ~isempty(strfind(funstrl,'cumsum('))
        Nops = 3;
    elseif ~isempty(strfind(funstrl,'sum(')) || ~isempty(strfind(funstrl,'int('))
        Nops = 2;
    elseif ~isempty(strfind(funstr,'D(')) || ~isempty(strfind(funstrl,'diff('))
        Nops = 1; % Well, we might as well give this a shot...
    end
end

if isempty(Nops)
    error('CHEBFUN:pde15s:inputs','Unable to parse input function.');
end

if QUASIN, Ndep = 1; else Ndep = syssize; end

Nind = Nin - Nops - Ndep;
% We don't accept only time or space as input args (both or nothing).
if ~(Nind == 0 || Nind == 2)
    error('CHEBFUN:pde15s:inputs_ind',['Incorrect number of independant variables' ...
        ' in input function. (Must be 0 or 2).']);
end
% Convert infun to accept quasimatrix inputs and remove ops from fun handle
ops = opslist(1:Nops);
if QUASIN
    if Nind == 0
        outfun = @(u,t,x) infun(u,ops{:});
    elseif Nind == 2
        outfun = @(u,t,x) infun(u,t,x,ops{:});
    end
else
    if Nind == 0
        outfun = @(u,t,x) conv2cell(infun,u,ops{:});
    elseif Nind == 2
        outfun = @(u,t,x) conv2cell(infun,u,t,x,ops{:});
    end
end

    function newfun = conv2cell(oldfun,u,varargin)
    % This function allows the use of different variables in the anonymous 
    % function, rather than using the clunky quasi-matrix notation.
        tmpcell = cell(1,syssize);
        if ( isa(u, 'chebfun') )
            for qk = 1:syssize
                tmpcell{qk} = u(qk);
            end
        else
            for qk = 1:syssize
                tmpcell{qk} = u(:,qk);
            end
        end
        newfun = oldfun(tmpcell{:},varargin{:});
    end

end
