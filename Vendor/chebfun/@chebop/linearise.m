function [L linBC isLin affine] = linearise(N,u,linCheck)
%LINEARISE   Linearise a chebop.
% [L LINBC] = LINEARISE(N,U) linearises the chebop N about the chebfun U. 
% If U is empty or not given, a suitable U is chosen using FINDNUMVAR.
%
% [L LINBC ISLIN] = LINEARISE(N,U) returns also a binary flag ISLIN which
% states whether components of the chebop N were already linear. ISLIN is a
% four-vector, which the first entry indicating the op is linear, and the
% final three the left, right, and 'other' BCs respectively.
%
% [L LINBC ISLIN F] = LINEARISE(N,U) returns a chebfun F of the affine part
% of N (which cannot be stored in a linop) such that N(x,u) - L*u = F(x).
%
% [~ ~ ISLIN] = LINEARISE(N,U,1) is simply a linearity check, and 
% linearisation is halted as soon as nonlinearity is detected. (This is
% also used by CHEBOP/ISLINEAR and CHEBOP/LINOP).
%
% See also CHEBOP/ISLINEAR CHEBOP/LINOP CHEBOP/FINDGUESS CHEBOP/DIFF

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%% Setup

% If linCheck == 1, we will break as soon as we encounter nonlinearity
if nargin < 3, linCheck = 0; end

% For EXPM, we need to be able to linearize around u = 0, so we offer 
% the option of linearizing around a certain function here.
if nargin == 1 || isempty(u)
    if isempty(N.domain)
        error('CHEBFUN:chebop:linearise:emptydomain', ...
            'Cannot linearise a chebop defined on an empty domain.');
    end
    if isempty(N.init)
        %   Create a chebfun to let the operator operate on. Using the
        %   findNumVar method ensures that the guess is of the right
        %   (quasimatrix) dimension.
        u = findNumVar(N);
    else
        u = N.init;
    end
end

% We don't want any jacobian info hanging around in the initial guess:
u = jacreset(u);

% We also want to make sure that all columns in a chebfun quasimatrix have
% a unique ID
u = newID(u);

% EXPERIMENTAL: Let's try ALWAYS setting the funreturn flag. 
%  We need to make sure the chebcont class is good enough to support this.
u = set(u,'funreturn',1);

% Initialise
isLin = ones(4,1);
linBC = [];
affine = [];
dom = N.domain.endsandbreaks;
a = dom(1); b = dom(end);
xDom = chebfun('x',dom);
jumpinfo = [];

% Check whether the anonymous function in N.op which accepts quasimatrices 
% or multiple variables, such as @(x,u,v). In the latter case we create a 
% cell array with entries for to each column of the quasimatrix 
% representing the current solution.
numberOfInputVariables = nargin(N.op);

% Load a cell with the colums of u.
if numberOfInputVariables > 1 
    uCell = cell(1,numel(u));
    for quasiCounter = 1:numel(u)
        uCell{quasiCounter} = u(:,quasiCounter);
    end
end

%% Functional part

if ~isa(N.op,'linop')
    if numberOfInputVariables > 1
        % If we have more than one variables, we know that the first one
        % must be the linear function on the domain.
        if numberOfInputVariables == 2 
        % Then we're working with @(x,u) where u might (or not) be a quasimatrix
            Nu = N.op(xDom,u);
        else
        % Then we're working with @(x,u,v,w,...)
            uTemp = [{xDom} uCell];
            Nu = N.op(uTemp{:});
        end
        % Obtain the Frechet derivative. nonConst contains information
        % about nonlinearity, including terms of the kind u.*v.
        [L nonConst] = diff(Nu,u,'linop');
    else
        Nu = N.op(u);
        [L nonConst] = diff(Nu,u,'linop');
    end
    
    % If there are any nonconst variables, then the chebop is nonlinear
    isLin(1) = ~any(any(nonConst));

    % Bail if linearity check and nonlinear
    if linCheck && ~isLin(1), return, end 
else
    L = N.op;
end


%% Boundary conditions part
% Check whether we have a mismatch between periodic BCs
if any(strcmpi(N.bc,'periodic')) && (~isempty(N.lbc) || ~isempty(N.rbc))
    error('CHEBOP:linearise:periodic', 'Mixed periodic and other BC types.');
end

if all(strcmpi(N.bc,'periodic'))
    % Need to treat periodic BCs specially
    linBC = 'periodic';
else
    % Left BC
    [linBC.left domL jumpinfoL isLin(2)] = lineariseBC(N.lbc,'left',linCheck);
    if linCheck && ~isLin(2), return, end % Bail if linearity check and nonlinear
    % Right BC
    [linBC.right domR jumpinfoR isLin(3)] = lineariseBC(N.rbc,'right',linCheck);
    if linCheck && ~isLin(3), return, end % Bail if linearity check and nonlinear
    % Other BCs
    [linBC.other domO jumpinfoO isLin(4)] = lineariseBC(N.bc,'other',linCheck,L.difforder, L.blocksize(2));
    if linCheck && ~isLin(4), return, end % Bail if linearity check and nonlinear
    
    % Combine recovered domains and jumplocs
    dom = unique([dom(:) ; domL(:) ; domR(:) ; domO(:)]).';
    jumpinfo = unique([jumpinfoL ; jumpinfoR ; jumpinfoO].','rows');
end

%% Tidy up

% Find the affine part (if requested)
if nargout > 3 
    if isa(N.op,'linop')
        affine = repmat(0*xDom,1,numberOfInputVariables-1);
    elseif ~isLin(1)
        affine = chebfun([],dom);
    elseif numberOfInputVariables == 1
        % Need a zeroFun which won't have funreturn == 1
        zeroFun = repmat(0*xDom,1,numel(u));
        affine = N.op(zeroFun);
    elseif numberOfInputVariables == 2 % Here we're working with @(x,u) where u could or could not be a quasimatrix
        zeroFun = repmat(0*xDom,1,numel(u));
        affine = N.op(xDom,zeroFun);
    else % Here we're working with @(x,u,v,...)
        uZero = repmat({0*xDom},1,numberOfInputVariables-1);
        affine = N.op(xDom,uZero{:});
    end
end

% Deal with jumps
jumpinfo = unique([jumpinfo ; N.jumpinfo],'rows');
if ~isempty(jumpinfo) && (any(jumpinfo(:,1)==a) || any(jumpinfo(:,1)==b))
    error('CHEBOP:linearise:jumpbcs',...
    ['Jump conditions cannot be enforced at the boundary of the domain.\n',...
     '(Do not use ''left'' or ''right'' flags at boundaries in .bc field.)'])
end
L = set(L,'jumpinfo',jumpinfo);

% Combine all the domain information
Ldom = get(L,'domain');
Ndom = N.domain; 
dom = unique([Ndom.endsandbreaks, Ldom.endsandbreaks, dom]);
L = set(L,'domain',domain(dom));

% Assign the scale to the linop if it's not empty
if ~isempty(N.scale),
    L = set(L,'scale',N.scale);
end

%% LineariseBC

    function [linBC dom jumpinfo isLin] = lineariseBC(bc,bctype,linCheck,difforder,syssize)
        % Attempt to linearise the boundary conditions
        % BCTYPE = 0 is a .LBC or .RBC, BCTYPE = 1 is a .BC
        
        % Initialise
        dom = [];
        jumpinfo = []; jumplocs = [];
        isLin = true;
        dummy = chebfun; % Make a dumy chebfun for fake feval calls
        
        if isempty(bc)
            linBC = struct([]); % Nothing to do here
            return
        elseif ~iscell(bc)
            bc = {bc};          % Wrap singleton in cell
        end  
       
        % Where to evaluate bc.
        domu = domain(u);
        endsu = domu.ends;
        switch bctype
            case 'left'
                ab = domu(1);
            case 'right'
                ab = domu(end);
            case 'other'
                ab = domu(1);
                u = set(u,'funreturn',1); % Set funreturn for 'other' bcs.
        end
        
        % Loop over each bc
        l = 1;  % Index for tracking number of recovered BCs
        for j = 1:length(bc)
            
            if isstruct(bc{j})
                % bc{j} is already in linop BC structure format
                numbcj = length(bc{j});
                linBC(l+(0:numbcj-1)) = bc{j}; %#ok<AGROW>
                for k = 1:numbcj
                    domk = get(bc{j}(k).op,'domain');
                    dom = union(dom,domk.endsandbreaks);
                end
                l = l+(1:numbcj);
                continue
                
            elseif ischar(bc{j}) && strcmp(bc{j},'periodic')
                  % mixed periodic and interior conditions                  
                  I = eye(domu);
                  D = diff(domu);
                  if syssize == 1 % Single system case
                      B = get(I,'varmat');
                      for k = 1:difforder
                        func = @(u) feval(diff(u,k-1),domu(1))-feval(diff(u,k-1),domu(end));
                        linBC(l) = struct('op',linop(B(1,:) - B(end,:),func,domu),'val',0);
                        l = l+1;
                        B = get(D,'varmat')*B;
                      end
                  else      % Systems case
                      order = max(difforder,[],1);
                      Z = zeros(A.domain); Z = Z.varmat;
                      for jj = 1:numel(order)
                          B = I.varmat;
                          Zl = repmat(Z,1,jj-1);
                          if jj > 1, Zl = Zl(1,:); end
                          Zr = repmat(Z,1,m-j);
                          if jj < m, Zr = Zr(1,:); end
                          for k = 1:order(jj)
                            linBC(l) = struct('op',linop([Zl B(1,:)-B(end,:) Zr],func,domu),'val',0);
                            l = l+1;
                            B = D.varmat*B;
                          end
                      end
                  end
                  continue
                  
            elseif nargin(bc{j}) > 1 + strcmp(bctype,'other')
                % @(x,u,v,w,...) format. Need to expand uCell to evaluate

                % Reset persistent variables storage in FEVAL.
                feval(dummy,[],'reset'); 

                % Evaluate the BC function
                if ~strcmp(bctype,'other')
                    guj = bc{j}(uCell{:});
                else
                    % funreturn flag should already be set
                    guj = bc{j}(xDom,uCell{:});
                end
                
                % Recover info from FEVAL and reset.
                [ignored jumpinfoj] = feval(dummy,[],'reset'); %#ok<ASGLU>                
                
                if strcmp(bctype,'other') && ~isa(guj,'chebconst')
                    error('CHEBFUN:chebop:linearise:funhandleBCs',...
                    ['Incorrect form of .BC: N.bc = %s.\n',...
                    'Function handles in .bc field should evaluate to scalars.\n',...
                    'See ''help chebop'' for details of allowed BC syntax.'],func2str(bc{j}));
                end

                % If the user assigns BCs of the form
                %   L.lbc = @(u,v) [u-1 ; v]; 
                % rather than 
                %   L.lbc = @(u,v) [u-1,v]; 
                % for a system, the domains of u and guj will not be
                % the same. Use that to throw an error.
                domguj = domain(guj);
                tol = eps*diff(endsu([1 end]));
                if abs(endsu(1) - domguj(1))>=tol || ...
                        abs(endsu(end) - domguj(end))>=tol                   
                    error('CHEBFUN:chebop:linearise:semicolonBCs',...
                        ['Incorrect form of %s BCs: %s\nTry @(u,v)[u;v] rather than @(u,v)[u,v]?\n',...
                        'See ''help chebop'' for details of allowed BC syntax.'],bctype,func2str(bc{j}));
                end
                
                % Deal with jump info.
                if strcmp(bctype,'other') && ~isempty(jumpinfoj)
                    njumps = numel(jumpinfoj);
                    jumplocs = [jumpinfoj.loc];
                    ID = reshape([jumpinfoj.ID].',2,njumps).';
                    jumpvars = zeros(1,njumps);
                    for k = 1:numel(uCell)
                        % Find FEVAL calls which match ID of input
                        idx = uCell{k}.ID(1) == ID(:,1) & uCell{k}.ID(2) == ID(:,2);
                        jumpvars(idx) = k;
                    end
                    jumporders = [jumpinfoj.Ord];
                    jumpinfo = [jumpinfo [jumplocs ; jumpvars ; jumporders]]; %#ok<AGROW>
                end
                
            else
                % Quasimatrix format
                
                % Reset persistent variables storage in FEVAL.
                feval(dummy,[],'reset'); 
                
                % Evaluate the BC function
                if nargin(bc{j}) == 1
                    guj = bc{j}(u);
                else
                    guj = bc{j}(xDom,u);
                end
                
                % Recover info from FEVAL and reset.
                [ignored jumpinfoj] = feval(dummy,[],'reset'); %#ok<ASGLU>
                
                if strcmp(bctype,'other') && ~isa(guj,'chebconst')
                    error('CHEBFUN:chebop:linearise:funhandleBCs',...
                    ['Incorrect form of .BC: N.bc = %s.\n',...
                    'Function handles in .bc field should evaluate to scalars.\n',...
                    'See ''help chebop'' for details of allowed BC syntax.'],func2str(bc{j}));
                end
                
                % Deal with jump info.
                if strcmp(bctype,'other') && ~isempty(jumpinfoj)
                    jumplocs = [jumpinfoj.loc];
                    njumps = numel(jumplocs);
                    ID = reshape([jumpinfoj.ID].',2,njumps).';
                    jumpvars = ones(1,njumps);
                    if numel(u) > 1
                        % Find FEVAL calls which match ID of input
                        for k = 1:numel(uCell)
                            idx = u(:,k).ID(1) == ID(:,1) & u(:,k).ID(2) == ID(:,2);
                            jumpvars(idx) = k;
                        end
                    end
                    jumporders = [jumpinfoj.Ord];
                    jumpinfo = [jumpinfo [jumplocs ; jumpvars ; jumporders]]; %#ok<AGROW>
                    jumpinfo = unique(jumpinfo.','rows').';
                end

            end
            
            % Compute the Frechet derivative of the BCs. 
            % Populate the structure linBC with the linops arising.
            gujvals = feval(guj,ab,'force'); % Evaluate (force double return)
            for k = 1:numel(guj);
                [Dgujk nonConstk] = diff(guj(:,k),u,'linop');
                isLin = isLin && ~any(any(nonConstk));
                if ~isLin && linCheck == 1, linBC = struct([]); return, end
                linBC(l) = struct('op',Dgujk,'val',-gujvals(k));%#ok<AGROW>
                l = l+1;
                domk = get(Dgujk,'domain');
                dom = union(dom, domk.endsandbreaks);
                dom = dom(:).';
            end
            
            % Include jumplocs in the domain
            if ~isempty(jumplocs)
                dom = union(dom,jumpinfo(1,:));
                dom = dom(:).';
            end

        end
    end

end