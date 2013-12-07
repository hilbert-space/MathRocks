function [u nrmDeltaRelvec isLin] = solvebvp_nonlin(N,rhs,u,pref,handles)
% SOLVE_BVP_ROUTINES Private function of the chebop class.
%
% This function gets called by nonlinear backslash and solvebvp. It both
% treats the cases where the user requests damped Newton iteration and
% pure Newton iteration.
%
% We can safely assume we have a u0 when we enter this method -- solvebvp.m
% takes care of obtaining the initial guess

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Damped Newton iteration. More details will follow.

restol = pref.restol;
deltol = pref.deltol;
maxIter = pref.maxiter;
maxStag = pref.maxstagnation;
dampedOn = strcmpi(pref.damped,'on');
% plotMode determines whether we want to stop between plotting iterations
plotMode = lower(pref.plotting);
lambda_minCounter = 0;

% Store the domain we're working with, and the endpoints of the domain
dom = N.domain;
ab = dom.ends;
a = ab(1);  b = ab(end);

% Create the linear function on the domain
xDom = chebfun('x',dom);

% !!! This should be done in solvebvp
% If RHS of the \ is 0, keep the original DE. If not, update it. Also check
% whether we have a chebop, if so, perform subtraction in a different way.
% The variable numberOfInputVariables is a flag that's used to evaluate
% functions in the function evalProblemFun.
if optype(N) == 2  % Operator is a linop. RHS is treated later
    deFun = N.op;
    numberOfInputVariables = 1;
elseif isnumeric(rhs) && all(rhs == 0)
    deFun = N.op;
    numberOfInputVariables = nargin(deFun);
elseif isnumeric(rhs)
    % If we have nonzeros on the RHSs, we need to convert the rhs from
    % vector to quasimatrix to allow subtraction and addition of columns
    rhsQuasimatrix = chebfun;
    for rhsCounter = 1:length(rhs)
        rhsQuasimatrix = [rhsQuasimatrix chebfun(rhs(rhsCounter),dom)];
    end
    deFunString = func2str(N.op);
    deFunArgs = deFunString(2:min(strfind(deFunString,')')));
    deFun = eval(['@', deFunArgs,' N.op', deFunArgs,'-rhsQuasimatrix']);
    numberOfInputVariables = nargin(deFun);
else
    % Need to do a string manipulation to make sure we're getting the
    % correct arguments for the new anonymous function
    deFunString = func2str(N.op);
    deFunArgs = deFunString(2:min(strfind(deFunString,')')));
    deFun = eval(['@', deFunArgs,' N.op', deFunArgs,'-rhs']);
    numberOfInputVariables = nargin(deFun);
end

% Create the variable currentGuessCell which is used for evaluation anon.
% function with multiple input variables
currentGuessCell = [];

% Extract BC functions
bcFunLeft = N.lbc;
bcFunRight = N.rbc;
bcFunOther = N.bc;


    
% Check whether either boundary has no BC attached, used later in the
% iteration.
leftEmpty = isempty(bcFunLeft);
rightEmpty = isempty(bcFunRight);
otherEmpty = isempty(bcFunOther);

% Wrap the DE and BCs in a cell
% if ~iscell(deFun), deFun = {deFun}; end
% if ~iscell(bcFunLeft), bcFunLeft = {bcFunLeft}; end
% if ~iscell(bcFunRight), bcFunRight = {bcFunRight}; end


% Anon. fun. and linops now both work with N(u)
[deResFun, lbcResFun, rbcResFun, bcResFun] = evalResFuns();

nrmDeltaRel = Inf;
nnormr = Inf;
nrmDeltaRelvec = zeros(maxIter,1);
normrvec = zeros(maxIter,1);
contraFactor = zeros(maxIter,1);
nrmDeltaAbsVec = zeros(maxIter,1);
normu = norm(u,'fro');

lambdas = zeros(10,1);
% Counter that checks whether we are stagnating. If we are doing pure
% Newton iteration, this counter will remain 0.
stagCounter = 0;

% Linearise N around the initial guess of the solution (which should
% satisfy linear BCs imposed). If we're in this method, we know that the
% problem is nonlinear, so we don't care about linearity information. Also,
% the affine part was already obtained in solvebvp (but do we need to take that into account in the differential equation?)
[A bc isLin] = linearise(N,u);
A = A & bc;
jumpinfo = get(A,'jumpinfo');

% Display information depending on whether we're in damped mode or not
if dampedOn
    solve_display(pref,handles,'initNewton',u);
else
    solve_display(pref,handles,'init',u);
end

% Pause to show the initial guess before starting the iteration
if strcmp(plotMode,'pause')
    pause
elseif ~strcmp(plotMode,'off')
    pause(plotMode)
end

% Counter for the Newton iteration to monitor the process
newtonCounter = 0;
while nrmDeltaRel > deltol && nnormr > restol && newtonCounter < maxIter && stagCounter < maxStag
    newtonCounter = newtonCounter + 1;
    
    % Obtain a struct including information for the BCs. Don't need to do
    % this at the first iteration as we already have the BCs from the
    % linearise method.
    if newtonCounter > 1
        bc = setupBC();
    end
    
    % If the operator is a linop, we don't need to linearize. Else, do the
    % linearization using diff. Note that if the operator is a linop, we
    % need to handle the rhs differently.
    if optype(N) == 1
        % Using A.scale if we are in the first iteration - Handles linear
        % problems better
        if newtonCounter == 1
            A = subsasgn(A,struct('type','.','subs','scale'), normu);
            delta = -(A\deResFun);
            % After the first iteration, we lower the tolerance of the chebfun
            % constructor (so not to use the default tolerance of chebfuns
            % but rather a size related to the tolerance requested).
        else
            A = diff(deResFun,u,'linop') & bc;
            A = set(A,'jumpinfo',jumpinfo);
            A = subsasgn(A,struct('type','.','subs','scale'), normu);
            % Linop backslash with the third argument added
            delta = -(A\deResFun);
            %             delta = -mldivide(A,deResFun,deltol);
        end
    else
        A = deFun & bc; % deFun is a LINOP
        
        % Do similar tricks as above for the tolerances.
        if newtonCounter == 1
            A = subsasgn(A,struct('type','.','subs','scale'), normu);
            delta = -(A\(r-rhs));
        else
            delta = -mldivide(A,r-rhs,deltol);
        end
    end
    
    % Find the optimal stepsize of the damped Newton iteration. Only use
    % damping if contraction factor is greater than 1
    nrmDeltaAbs = norm(delta,'fro');
    if newtonCounter > 1
        contraFactor(newtonCounter-1) = nrmDeltaAbs/nrmDeltaAbsVec(newtonCounter-1);
    end
    if dampedOn && (newtonCounter > 1 && contraFactor(newtonCounter-1) > 1)
        lambda = optStep();
    else
        lambda = 1;
    end
    
    % Add the correction to the current solution
    u = u + lambda*delta;
    u = jacreset(u);      % Reset the Jacobian of the function
    
    % Reset the currentGuessCell variable
    currentGuessCell = [];

    [deResFun, lbcResFun, rbcResFun, bcResFun] = evalResFuns;
    
    normu = norm(u,'fro');
    nrmDeltaRel = nrmDeltaAbs/normu;
    normr = solNorm/normu;
    nnormr = norm(normr);
    
    % In case of a quasimatrix, the norm calculations were taking the
    % longest time in each iterations when we used the two norm.
    % This was caused by the fact that we performed
    % svd in the norm calculations in case of quasimatrices.
    % A possible remedy was be to the simply take the inner product
    % columnwise and use the sum of those inner products as an estimate for
    % the residuals (this is certainly correct if the preferred norm is
    % be the Frobenius norm).
    nrmDeltaAbsVec(newtonCounter) = nrmDeltaAbs;
    nrmDeltaRelvec(newtonCounter) = nrmDeltaRel;
    normrvec(newtonCounter) = nnormr/normu;
    %     contraFactor =
    lambdas(newtonCounter) = lambda;
    
    if ~strcmp(plotMode,'off')
        if strcmp(plotMode,'pause')
            pause
        elseif newtonCounter > 1
            % Measure how long it is since we plotted last iteration
            iterationTimeToc = toc(iterationTimeTic);
            if plotMode - iterationTimeToc > 0
                pause(plotMode-iterationTimeToc)
            end
        end
    end
    % We want a slightly different output when we do a damped Newton
    % iteration. Also, in damped Newton, we check for stagnation.
    if dampedOn
        solve_display(pref,handles,'iterNewton',u,lambda*delta,nrmDeltaRel,normr,lambda)
        stagCounter = checkForStagnation(stagCounter);
    else
        solve_display(pref,handles,'iter',u,lambda*delta,nrmDeltaRel,normr)
    end
    
    % If the user has pressed the stop button on the GUI, we stop and
    % return the latest solution
    if ~isempty(handles) && strcmpi(get(handles.button_solve,'String'),'Solve')
        nrmDeltaRelvec(newtonCounter+1:end) = [];
        solve_display(pref,handles,'final',u,[],nrmDeltaRel,normr,nrmDeltaRelvec)
        return
    end
    
    % If the user has pressed the pause button on the GUI, we pause
    if ~isempty(handles) && strcmpi(get(handles.button_clear,'String'),'Continue')
        waitfor(handles.button_clear,'String')
    end
    
    % Start a timer from the end of this iteration
    iterationTimeTic = tic;
end
% Clear up norm vectors 
nrmDeltaRelvec(newtonCounter+1:end) = [];
solve_display(pref,handles,'final',u,[],nrmDeltaRel,normr,nrmDeltaRelvec)

% Issue a warning message if stagnated. Should this in output argument
% (i.e. flag)?
if stagCounter == maxStag
    if ~isempty(handles)
        w = warndlg('Function exited with stagnation flag.','Stagnation','modal');
        uiwait(w)
    else
        warning('CHEBOP:Solvebvp', 'Function exited with stagnation flag.')
    end
end

% Function which returns all residual functions
    function [deResFun, lbcResFun, rbcResFun, bcResFun] = evalResFuns()
        
        deResFun = evalProblemFun('DE',u);
        if ~leftEmpty
            lbcResFun = evalProblemFun('LBC',u);
        else
            lbcResFun = 0;
        end
        if ~rightEmpty
            rbcResFun = evalProblemFun('RBC',u);
        else
            rbcResFun = 0;
        end
        if ~otherEmpty
            bcResFun = evalProblemFun('BC',set(u,'funreturn',1));
        else
            bcResFun = 0;
        end        
        
    end
% Function that sets up the boundary conditions of the linearized operator
    function bcOut = setupBC()
        % If we have a periodic BC, simply let bc be 'periodic'. We have
        % already checked whether both left and right BCs are both periodic
        % or not, so no need to check both left and right.
        if strcmpi(bcFunOther,'periodic')
            bcOut = 'periodic';
        else
            % Check whether a boundary happens to have no BC attached
            if leftEmpty
                bcOut.left = [];
            else
                v = lbcResFun;
                va = feval(v,a);
                for j = 1:numel(v);
                    bcOut.left(j) = struct('op',diff(v(:,j),u,'linop'),'val',va(j));
                end
            end
            % Check whether a boundary happens to have no BC attached
            if rightEmpty
                bcOut.right = [];
            else
                v = rbcResFun;
                vb = feval(v,b);
                for j = 1:numel(v);
                    bcOut.right(j) = struct('op',diff(v(:,j),u,'linop'),'val',vb(j));
                end
            end
            % Check whether a boundary happens to have no BC attached
            if otherEmpty
                bcOut.other = [];
            else
                v = bcResFun;
                vb = feval(v,b,'force');
                for j = 1:numel(v);
                    bcOut.other(j) = struct('op',diff(v(:,j),u,'linop'),'val',vb(j));
                end
            end
            
        end
    end

% Function that measures how far away we are from the solving the BVP.
% This function takes into account the differential equation and the
% boundary values.
    function sn = solNorm
        sn = [0 0];
        
        % Need to check whether we satisfy BCs in a different way if we
        % have periodic BCs (i.e. we check for example whether u(0) = u(1),
        % u'(0) = u'(1) etc.).
        if strcmpi(bcFunOther,'periodic')
            diffOrderA =  get(A,'difforder');
            for orderCounter = 0:diffOrderA - 1
                sn(2) = sn(2) + norm(feval(diff(u,orderCounter),b)-feval(diff(u,orderCounter),a))^2;
            end
        else
            % Evaluate residuals of BCs
            if ~leftEmpty
                va = feval(lbcResFun,a,'force');
                sn(2) = sn(2) + va*va';
            end
            
            if ~rightEmpty
                vb = feval(rbcResFun,b,'force');
                sn(2) = sn(2) + vb*vb';
            end
            
            if ~otherEmpty
                vb = feval(bcResFun,b,'force');
                sn(2) = sn(2) + vb*vb';
            end
        end
        
        if optype(N) == 1
            sn(1) = sn(1) + norm(deResFun,'fro').^2;
        else
            sn(1) = sn(1) + norm(r-rhs,'fro').^2;
        end
        
        sn = sqrt(sn);
    end

    function lam = optStep()
        % Parameters for damping. Eventually, they will be available for
        % the user to set in options.
        sigma = 0.01; lambda_min = 0.1; tau = 0.1;
        
        % The objective function we want to minimize.
        
        % This objective function does not take into account BCs.
        %         g = @(a) 0.5*norm(A\deFun(u+a*delta),'fro').^2;
        
        % Objective function with BCs - Using the functions.
        %         g = @(a) 0.5*(norm(A\evalProblemFun('DE',u+a*delta),'fro').^2 +bcResidual(u+a*delta));
        
        % Objective function without BCs - Using the functions.
        g = @(a) 0.5*(norm(A\evalProblemFun('DE',u+a*delta),'fro')).^2;
        
        % Objective function with BCs - Using linearized BCs
        %         g = @(a) 0.5*(norm(A\deFun(u+a*delta),'fro').^2 +bcResidual2(u+a*delta));
        %          g = @(a) 0.5*(norm(A\deFun(u+a*delta),'fro').^2 + ...
        %             norm(bcLeftOp\(deFun(u+a*delta),'fro').^2);
        %         g = @(a) 0.5*(norm(deFun(u+a*delta),'fro').^2 +bcResidual(u+a*delta));
        g0 = g(0);
        
        % Check whether the full Newton step is acceptable. If not, we
        % search for a mininum using fminbnd.
        %                 g1 = g(1);
        %                 if g1 < (1-2*sigma)*g0
        %                     lam = 1;
        %                 else
        %                     amin = fminbnd(g,0.095,1);
        %                     lam = amin;
        %                 end
        %                 if lam < lambda_min
        %                     if lambda_minCounter < 3
        %                         lambda_minCounter = lambda_minCounter + 1;
        %                         lam = lambda_min;
        %                     else
        %                         %If we take three smallest step in a row, give the
        %                         %solution process a "kick".
        %                         lam = .6;
        %                         lambda_minCounter = lambda_minCounter - 1;
        %                     end
        %                 end
        %
        % Explicit calculations, see Ascher, Mattheij, Russell [1995]
        
        lam = 1;
        accept = 0;
        while ~accept && lam > lambda_min
            glam = g(lam);
            if glam <= (1-2*lam*sigma)*g0
                accept = 1;
            else
                lam = max(tau*lam,(lam^2*g0)/((2*lam-1)*g0+glam));
            end
        end
        if lam <= lambda_min
            if lambda_minCounter < 3
                lambda_minCounter = lambda_minCounter + 1;
                lam = lambda_min;
            else
                % If we take three smallest step in a row, give the
                % solution process a "kick".
                lam = 1;
                lambda_minCounter = lambda_minCounter - 1;
            end
        end
    end

% Function used in the stagnation check for damped Newton iteration.
    function updatedStagCounter = checkForStagnation(currStagCounter)
        if nrmDeltaRel > min(nrmDeltaRelvec(1:newtonCounter)) && norm(normr)/normu > min(normrvec(1:newtonCounter))
            updatedStagCounter = currStagCounter+1;
        else
            updatedStagCounter = max(0,currStagCounter-1);
        end
    end

    function fOut = evalProblemFun(type,currentGuess)
        % Don't need to take any special measurements if the number of
        % input arguments is not greater than 1.
        
        % We have already created a flag which tells us whether the
        % anonymous functions in the problem take one argument (i.e. a
        % whole quasimatrix) or more (e.g. @(u,v)). In the former case,
        % no special measurements have to be taken, but in the latter, in
        % order to allow evaluation, we need to create a cell array with
        % entries equal to each column of the quasimatrix representing the
        % current solution.
        
        currentGuess = jacreset(currentGuess);
        
        if numberOfInputVariables == 1
            switch type
                case 'DE'
                    fOut = deFun(currentGuess);
                case 'LBC'
                    if ~iscell(bcFunLeft)
                        fOut = bcFunLeft(currentGuess);
                    else
                        fOut = chebfun;
                        for funCounter = 1:length(bcFunLeft)
                            fOut(:,funCounter) = feval(bcFunLeft{funCounter},currentGuess);
                        end
                    end
                case 'RBC'
                    if ~iscell(bcFunRight)
                        fOut = bcFunRight(currentGuess);
                    else
                        fOut = chebfun;
                        for funCounter = 1:length(bcFunRight)
                            fOut(:,funCounter) = feval(bcFunRight{funCounter},currentGuess);
                        end
                    end
                case 'BC'
                    if ~iscell(bcFunOther)
                        if strcmpi(bcFunOther,'periodic')
                            fOut = chebfun(0,dom);
                        elseif nargin(bcFunOther) == 1
                            fOut = bcFunOther(currentGuess);
                        else
                            fOut = bcFunOther(set(xDom,'funreturn',1),currentGuess);
                        end
                    else
                        fOut = chebfun;
                        if nargin(bcFunOther) == 1
                            for funCounter = 1:length(bcFunOther)
                                fOut(:,funCounter) = feval(bcFunOther{funCounter},currentGuess);
                            end
                        else
                            for funCounter = 1:length(bcFunOther)
                                fOut(:,funCounter) = feval(bcFunOther{funCounter},set(xDom,'funreturn',1),currentGuess);
                            end
                        end
                    end                    
            end
        elseif numberOfInputVariables == 2 % Now we're working with @(x,u) where u could be a single column or a quasimatrix
            switch type
                case 'DE'
                    fOut = deFun(xDom,currentGuess);
                case 'LBC'
                    fOut = bcFunLeft(currentGuess);
                case 'RBC'
                    fOut = bcFunRight(currentGuess);
                case 'BC'
                    if strcmpi(bcFunOther,'periodic')
                        fOut = chebfun(0,dom);
                    else
                        if nargin(bcFunOther) == 1
                            fOut = bcFunOther(currentGuess);
                        else
                            fOut = bcFunOther(set(xDom,'funreturn',1),currentGuess);
                        end
                    end
            end
        else % Now we're working with @(x,u,v)
            % Load the cell variable
            if isempty(currentGuessCell)
                currentGuessCell = cell(1,numel(currentGuess));
                for quasiCounter = 1:numel(currentGuess)
                    currentGuessCell{quasiCounter} = currentGuess(:,quasiCounter);
                end
            end
            
            if strcmp(type,'BC')
                for k = 1:numel(currentGuessCell)
                    currentGuessCell{k} = set(currentGuessCell{k},'funreturn',1);
                end
            else
                for k = 1:numel(currentGuessCell)
                    currentGuessCell{k} = set(currentGuessCell{k},'funreturn',0);
                end
            end
            
            switch type
                case 'DE'
                    fOut = deFun(xDom,currentGuessCell{:});
                case 'LBC'
                    fOut = bcFunLeft(currentGuessCell{:});
                case 'RBC'
                    fOut = bcFunRight(currentGuessCell{:});
                case 'BC'
                    if strcmpi(bcFunOther,'periodic')
                        fOut = chebfun(0,dom);
                    else
                        if nargin(bcFunOther) == numel(currentGuessCell)
                            fOut = bcFunOther(currentGuessCell{:});
                        else
                            fOut = bcFunOther(set(xDom,'funreturn',1),currentGuessCell{:});
                        end
                    end                    
            end
        end
    end


end