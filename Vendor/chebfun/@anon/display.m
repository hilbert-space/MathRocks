function display(A,maxdepth,curdepth,ws)
% DISPLAY Pretty-print an anon
% DISPLAY is called automatically when a statement that results in an anon
% output is not terminated with a semicolon.
% DISPLAY(A,MAXDEPTH) will descend the anon tree upto MAXDEPTH levels and
% pretty-print the corresponding anons. By default MAXDEPTH is 1. Setting it
% to INF will force DISPLAY to descend to the bottom of the tree.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Defaults
if nargin < 2, maxdepth = inf; end
if nargin < 3, curdepth = 1; end

% We don't want to go any further
if curdepth > maxdepth, return, end

% Initialise white space
if nargin < 4
    ws = ['   ' repmat('     ',1,curdepth-1)];
elseif isempty(ws)
    ws = '   ';
end

% Initialise string to print
s = [];

if curdepth == 1
    % Attempt to grab variable name
    name = inputname(1);
    if isempty(name), name = 'ans'; end
    disp([name ' ='])
    
    % Deal with empty anons
    if isempty(A)
        disp([ws, 'empty anon']);    
        return
    end
    % Anon is not empty
    disp([ws 'anon']);
    
    % Initialise s
    s = [s, sprintf('\n%sdiff(%s,u) = ',ws,name)];
end

varNamesStr = [];
varsNames = A.variablesName;
for k = 1:numel(varsNames)
%     if ~isa(A.workspace{k},'chebfun'), continue, end
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
    disp(s);
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

% Clean out 'linop' flags and break at semicolons for pretty print
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
    if isempty(funcStrClean{k}), continue, end
    s = [s,sprintf('\n%s%s',ws,funcStrClean{k})];
%     s = [s,sprintf(' %s',funcStrClean{k})];
end

% Print the output
disp(s)

% We don't want to go any further
if curdepth == maxdepth, return, end

% Recurse down the tree
wsnew1 = [ws '|     '];
wsnew2 = [ws '|---- '];
wsnew3 = [ws '      '];

% Get the indices of the variables which have extra levels to display
mask = zeros(numel(A.workspace),1);
for k = 1:numel(A.workspace)
    fk = A.workspace{k};
    % Uncomment below to prevent showing empty anons
    if isa(fk,'chebfun') %&& ~isempty(fk.jacobian.variablesName)
        mask(k) = 1;
    elseif iscell(fk) && ~isempty(fk) && isa(fk{1},'chebfun') %&& ~isempty(fk.jacobian.variablesName)
        mask(k) = 1;
    end
end   
idx = find(mask);

% If there are no more levels, then quit
if isempty(idx), return, end

% Display the next levels for each variable in turn
for k = idx(1:end-1)'
    if isempty(k), continue, end
    fk = A.workspace{k};
    if iscell(fk)
        for j = 1:numel(fk)
            fprintf('%s\n%sdiff(%s{%d},u) = ',wsnew1,wsnew2,varsNames{k},j);
            display(fk{j}.jacobian,maxdepth,curdepth+1,wsnew1)
        end
    else
        fprintf('%s\n%sdiff(%s,u) = ',wsnew1,wsnew2,varsNames{k});
        display(fk.jacobian,maxdepth,curdepth+1,wsnew1)
    end
end   
% The last variable is treated specially (to get lines correct).
k = idx(end);
fk = A.workspace{k};
fprintf('%s\n%sdiff(%s,u) = ',wsnew1,wsnew2,varsNames{k});
display(fk.jacobian,maxdepth,curdepth+1,wsnew3)

end
