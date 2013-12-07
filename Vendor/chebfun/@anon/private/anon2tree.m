function [t found] = anon2tree(an,varName,ID)
% ANON2TREE Convert anon to a recursively defined tree (used for plotting
% an displaying anon).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Access variables (and the number of them) in the workspace of the input
% anon
variablesVec = 1:length(an.variablesName);
varNames = an.variablesName;
workspace = an.workspace;

found = 0;
foundHere = [0 0 0];
foundBelow = [0 0 0];

% Store the anon in the info field of the structure. To display more
% informative strings, we need to know the name of the input variable if
% possible (otherwise, all first lines will be of the form diff(an,u) = ...

% Attempt to grab variable name
if nargin > 1 && ~isempty(varName)
    name = varName;
else
    name = inputname(1);
    if isempty(name), name = 'ans'; end
end
if nargin < 3, ID = []; end

% Store string displayed as information
t.info = {func2str(an,name)};
% Store parent information
if isempty(an.parent)
    parent = 'x';
else
    parent = an.parent;
    if strcmp(parent,'plus'), parent = '+';
    elseif strcmp(parent,'minus'), parent = '-';
    elseif strcmp(parent,'times'), parent = '.*';
    elseif strcmp(parent,'mtimes'), parent = '*';
    elseif strcmp(parent,'rdivide'), parent = './';
    elseif strcmp(parent,'mdivide'), parent = '/';
    elseif strcmp(parent,'power'), parent = '^';
    end
end
t.parent = parent;

% Go through workspace to detect what variables are chebfuns, and which are
% scalars/strings
for wsCounter = length(variablesVec):-1:1
    if ~isa(workspace{wsCounter},'chebfun')
        variablesVec(wsCounter) = [];
    end 
end

numVariables = length(variablesVec);
for counter = 1:numVariables
    if ~isempty(ID)
        IDk = get(workspace{variablesVec(counter)},'ID');
        foundHere(counter) = ID == IDk(1);
    end 
end

% Do if-else depending on how many chebfun variables we have in the
% workspace. As we might have doubles in the workspace, we need to subsref
% the workspace using the information in the variablesVec vector, e.g. for
% 2^x, we want the second variable in the workspace as a leaf, not the
% first one.
numVariables = length(variablesVec);
if numVariables == 0 % End recursion
    % Store the height and width of the leave, do nothing else
    t.height = 0;
    t.width = 1;
    t.numleaves = 0;
    %     t.x = 0.5;
elseif numVariables == 1
    [t.center foundBelow(2)] = anon2tree(workspace{variablesVec(1)}.jacobian,varNames{variablesVec(1)},ID);
    t.height = t.center.height + 1;
    t.width = t.center.width;
    t.numleaves = 1;
    foundBelow(2) = foundBelow(2) | foundHere(1);
    % Don't need to worry about scaling x coordinate
elseif numVariables == 2
    [t.left foundBelow(1)] = anon2tree(workspace{variablesVec(1)}.jacobian,varNames{variablesVec(1)},ID);
    [t.right foundBelow(3)] = anon2tree(workspace{variablesVec(2)}.jacobian,varNames{variablesVec(2)},ID);
    t.height = max(t.left.height,t.right.height) + 1;
    t.width = t.left.width + t.right.width;
    t.numleaves = 2;
    foundBelow([1 3]) = foundBelow([1 3]) | foundHere([1 2]);
    % Scale x coordinates
    %     t.x = 0.5;
    %     t.left.x
elseif numVariables == 3
    [t.left foundBelow(1)] = anon2tree(workspace{variablesVec(1)}.jacobian,varNames{variablesVec(1)},ID);
    [t.center foundBelow(2)] = anon2tree(workspace{variablesVec(2)}.jacobian,varNames{variablesVec(2)},ID);
    [t.right foundBelow(3)] = anon2tree(workspace{variablesVec(3)}.jacobian,varNames{variablesVec(3)},ID);
    t.height = max(max(t.left.height,t.right.height),t.center.height) + 1;
    t.width = t.left.width + t.center.width + t.right.width;
    t.numleaves = 3;
    foundBelow = foundBelow | foundHere;
end

t.found = foundBelow;
found = any(foundBelow);


end