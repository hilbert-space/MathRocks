function varargout = feval(Fin,u,anonType)
% FEVAL Evaluates an anon with an input argument, similar to f(u) where f
% is an anonymous function and u is the argument.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 3
    anonType = 2;
end
if isempty(Fin.func)
    error('Unable to evaluate AD derivative, maximum AD depth reached. Try increasing chebfunpref(''ADdepth''). Please contact the chebfun team at chebfun@maths.ox.ac.uk for more information.');
elseif anonType == 1 && Fin.depth == 1 % Base variable, return []
    varargout{1} = []; varargout{2} = 0;
    return;
end
% Extract variable names and values
Fvar = Fin.variablesName;
Fwork = Fin.workspace;

% Load these variables into workspace
loadVariables(Fvar,Fwork)

% Need different evaluations depending on the type of the anon. For AD
% information, we evaluate the string. For other uses of anons, e.g. for
% oparrays, we create the anonymous function and return it.
% Evaluate the string in Fin.function. This will return the output
% variables of the feval function of anons.
switch anonType
    case 1
        eval(Fin.func); 
        varargout{1} = der; varargout{2} = nonConst;
    case 2
        % Create a normal anonymous function handle that we can then evaluate
        Ffun = eval(Fin.func);
        varargout{1}= feval(Ffun,u);
end
end

function loadVariables(Fvar,Fwork)
for i=1:length(Fvar), assignin('caller',Fvar{i},Fwork{i}), end
end