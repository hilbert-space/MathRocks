function [u nrmDeltaRelvec] = solvebvp_lin(L,rhs,affine,pref,handles)

% Correct for bc vals by using information from the affine part.
if isnumeric(rhs)
    if numel(rhs) == 1
        bs = get(L,'blocksize');
        rhs = repmat(rhs,1,bs(1));
    end
end

% !!! This probably needs to be addressed properly when RHS is a
% quasimatrix
newRhs = chebfun;
if ~isempty(affine)
    for rhsCounter = 1:numel(rhs)
        newRhs(:,rhsCounter) = rhs(:,rhsCounter) - affine(:,rhsCounter);
    end
else
    newRhs = rhs;
end

% Solve the linear system, using the linop mldivide
u = L\newRhs;
% delta = uguess-u;

if nargout == 2
    nrmDeltaRelvec = norm(L*u-newRhs);
end

% Display information depending on whether we're running from the GUI or
% from command line/.m files
if isempty(handles) && any(strcmpi(pref.display,{'iter','display'}))
    fprintf('Converged in one step. (Chebop is linear).\n');
elseif ~isempty(handles)
    solve_display(pref,handles,'init',u);
    normu = norm(u);
    % Give dummy arguments to the solve display method -- we don't display
    % anything anyway about norm of updates when the problem is linear.
    solve_display(pref,handles,'iter',u,[],[],[])
    solve_display(pref,handles,'final',u,[],normu,0)
end
