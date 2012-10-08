function includeLibrary(name)
  path = [ root, '/', name ];
  hook = [ path, '/', 'setup.m' ];
  if exist(path, 'dir')
    addpath(path);
    if exist(hook, 'file')
      run(hook);
    end
  else
    warning('An attempt to include a non-existing library "%s".', name);
  end
end

function path = root
  chunks = regexp(mfilename('fullpath'), '^(.*)/[^/]+$', 'tokens');
  path = chunks{1}{1};
end
