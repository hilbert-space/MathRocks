function initialize
  addLibrary('Helpers');
end

function addLibrary(name)
  addpath([ rootPath, '/', name ]);
end

function path = rootPath
  chunks = regexp(mfilename('fullpath'), '^(.*)/[^/]+/[^/]+$', 'tokens');
  path = chunks{1}{1};
end
