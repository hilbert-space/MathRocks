function includeLibrary(name)
  root = traceLocation();
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
