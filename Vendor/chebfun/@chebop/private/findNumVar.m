function guess = findNumVar(N)
% FINDNUMVAR Finds the number of variables a chebop operates on.
%
% FINDNUMVAR starts by checking whether the operator of N takes multiple
% arguments, that's an indicator the quasimatrix syntax is not being used.
% If not, it creates a quasimatrix with one column (the zero chebfun), then
% adds another column with the zero function to the quasimatrix until it's
% able to apply the operator to the quasimatrix (which means that the
% quasimatrix is then of the correct size). E.g., for
%
%   N = chebop(@(x,u) diff(u,2))
%
% findNumVar will return a single zero chebfun, but for
%
%   N = chebop(@(x,u,v) [diff(u,2),diff(v,2)])
%
% it will return a quasimatrix consisting of two zero chebfuns.


% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

guess = [];
dom = N.domain;
xDom = chebfun('x',dom);
Ndim = N.dim;
success = 0;
counter = 0;


% If N.op takes multiple arguments (i.e. on the form @(x,u,v)), we know how
% many columns we'll be needing in the quasimatrix. We also know that the
% linear function x will be the first argument.
NopArgin = nargin(N.op);

if NopArgin > 1
    success = 1;
    
    for quasiCounter = 2:NopArgin
        cheb0 = chebfun(0,dom);
        guess = [guess cheb0];
    end
elseif NopArgin == 1 && ~isempty(Ndim)
    success = 1;
    
    for quasiCounter = 1:Ndim
        cheb0 = chebfun(0,dom);
        guess = [guess cheb0];
    end
end

% Won't be called if NopArgin > 1 since then we are already successful. We
% only go into the if statement here if we have a chebop with a quasimatrix
% syntax ( N.op = @(u) [diff(u(:,1)), diff(u(:,2)]), so in most cases, this
% is not called.
while ~success && counter < 10
    % Need to create new chebfun at each step in order to have the
    % correct ID of the chebfun
    cheb0 = chebfun(0,dom);
    guess = [guess cheb0];
    
    
    % Check whether we are successful in applying the operator to the
    % function.
    try
        if NopArgin == 1
            feval(N.op,guess);
        else
            guessTemp = [xDom guess];
            feval(N.op,guessTemp{:});
        end
        success = 1;
        counter = counter+1;
    catch ME
        if strcmp(ME.identifier,'CHEBFUN:mtimes:dim') || strcmp(ME.identifier,'MATLAB:badsubscript')
            counter = counter + 1;
        elseif strcmp(ME.identifier,'CHEBFUN:rdivide:DivisionByZeroChebfun')
            error('CHEBOP:solve:findguess:DivisionByZeroChebfun', ...
                ['Error in constructing initial guess. The the zero function ', ...
                'on the domain is not a permitted initial guess as it causes ', ...
                'division by zero. Please assign an initial guess using the ', ...
                'N.init field.']);
        else
            error('CHEBOP:solve:findguess:ZeroFunctionNotPermitted', ...
                ['Error in constructing initial guess. The zero function ', ...
                'appears not to be valid as an argument to the operator. ', ....
                'Please assign an initial guess using the N.init field.']);
        end
    end
end

if counter == 10
    error('CHEBOP:solve:findguess', ['Initial guess seems to have 10 or more ' ...
        'columns in the quasimatrix. If this is really the case, set the ' ...
        'initial guess using N.init.']);
end