function profile(time)
  if nargin > 0
    time = toc(time);
  end

  profile report;
  profile off;

  if nargin > 0
    fprintf('Profiling is done in %.2f seconds.\n', time);
  end
end
