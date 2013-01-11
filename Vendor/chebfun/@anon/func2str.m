function s = func2str(A,name)
%FUNC2STR Convert the function field in anons to a pretty string for a
%   single anon (i.e. don't do anything recursive).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Find variable name if possible. Don't need to do that if we have two
% input arguments
if nargin < 2
    % attempt to grab variable name
    name = inputname(1);
    if isempty(name), name = 'ans'; end
end

% deal with empty anons
if isempty(A.variablesName)
    s = 'empty anon';
    return
end

% initialise s
s = sprintf('diff(%s,u) = ',name);

varNamesStr = [];
varsNames = A.variablesName;
for k = 1:numel(varsNames)
    if isempty(varNamesStr)
        varNamesStr = varsNames{k};
    else
        varNamesStr = [varNamesStr,',',varsNames{k}];
    end
    vark = A.workspace{k};
    if isnumeric(vark)
        classk = num2str(vark);
    elseif ischar(A.workspace{k})
        classk = ['''' vark ''''];
    else
        classk = class(vark);
    end
    varNamesStr = [varNamesStr '=' classk];
end
% Update s to contain the variables string
if isempty(varNamesStr)
    s = [s, sprintf('empty anon')];
    return
end
s = [s, sprintf('@(%s): ',varNamesStr)];

% Include the parent tag if present
if ~isempty(A.parent)
    parent = A.parent;
    % If java is not enabled, don't display html links.
    if usejava('jvm') && usejava('desktop') 
        whichParent = which([parent '(chebfun)']);
        parent = ['<a href="matlab: edit ''' whichParent '''">' parent '</a>'];
    end
    s = [s, '%', parent];
end

% Grab the main function string
funcStr = A.func;

% Clean out 'linop' flags and break at semicolons for prettyprint
idx = [0 strfind(funcStr,';')];
idx = sort([idx [strfind(funcStr,'&&') strfind(funcStr,'||')]+1]);
funcStrClean = {};
for k = 1:numel(idx)-1;
    funcStrClean{k} = funcStr(idx(k)+1:idx(k+1));
    while numel(funcStrClean{k})>1 && isspace(funcStrClean{k}(1))
        funcStrClean{k}(1) = [];
    end
    funcStrClean{k} = strrep(funcStrClean{k},',''linop''','');
    funcStrClean{k} = strrep(funcStrClean{k},'&&','&& ...');
    funcStrClean{k} = strrep(funcStrClean{k},'||','|| ...');
    if k > 1 && strcmp(funcStrClean{k-1}(end-2:end),'...')
        funcStrClean{k} = ['      ' funcStrClean{k}]; 
    end
end

% Print each function string on a new line
for k = 1:numel(funcStrClean)
    s = [s,sprintf('\n%s',funcStrClean{k})];
end


end

