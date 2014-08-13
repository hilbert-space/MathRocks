function path = choose(directories, filename)
  for i = 1:length(directories)
    path = File.join(directories{i}, filename);
    if File.exist(path), return; end
  end
  assert(false);
end
