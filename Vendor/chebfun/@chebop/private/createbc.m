function bcOut = createbc(bcArg,numvar)
% CREATEBC Converts various types of allowed BC syntax to correct form.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% If numvar is empty, N.op has not yet been assigned. Set numvar to 1 and
% try to carry on. Here we could throw an error if we'd like to force N.op
% to be assigned before BCs.
if isempty(numvar), numvar = 1; end

if strcmp(bcArg,'neumann')
    % Only support neumann and dirichlet for one unknown function
    if numvar <= 2
        bcOut = @(u) diff(u);
    else
        error('CHEBFUN:chebop:createbc:keywordSystem',['''neumann'' boundary condition is not valid for systems of equations.',...
            '\n\nSee ''help chebop'' for details of allowed syntax.']);
    end
elseif strcmp(bcArg,'dirichlet')
    % Only support neumann and dirichlet for one unknown function
    if numvar <= 2
        bcOut = @(u) u;
    else
        error('CHEBFUN:chebop:createbc:keywordSystem',['''dirichlet'' boundary condition is not valid for systems of equations.',...
            '\n\nSee ''help chebop'' for details of allowed syntax.']);
    end
elseif ~isempty(bcArg) && isnumeric(bcArg)
    % If we only have one unknown variable we don't need to do much --
    % simply create an anonymous function which will evaluate to zero if
    % the BC is satisfied
    if numvar <= 2
        val = bcArg;
        bcOut = @(u) u-val;
    elseif length(bcArg) == 1
        % Create a new vector with the BC value repeated
        bcArg = repmat(bcArg,numvar-1,1);
        bcOut = createbc(bcArg,numvar);
    elseif length(bcArg) == numvar - 1
        % This is OK. Create anonymous function of the form
        % @(u1,u2,...)[u1-val(1),u2-val(2),...]
        argString = [];
        funString = [];
        for bcCounter = 1:length(bcArg)
            argString = [argString,'u',num2str(bcCounter),','];
            funString = [funString,'u',num2str(bcCounter),'-',num2str(bcArg(bcCounter)),','];
        end
        argString(end) = []; % Delete the last ,
        funString(end) = []; % Delete the last ,
        
        % Evaluate to an anonymous funtion
        bcOut = eval(['@(',argString,')[',funString,']']);
    else
        error('CHEBFUN:chebop:createbc','Boundary condition do not have the correct dimension.')
    end
elseif iscell(bcArg) % BC-s of the form {1, @(u)diff(u)};
    sizebcArg = size(bcArg);
    numvar = repmat({numvar},sizebcArg(1),sizebcArg(2));
    % Need to convert the doubles to anonymous functions.
    bcOut = cellfun(@createbc,bcArg,numvar,'uniform',false);
else
    % If we get here, only option left is a BC already on the an. function
    % form or a empty variable, so we simply use that.
    bcOut = bcArg;
end

end