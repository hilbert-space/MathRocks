function profile(varargin)
  profile on;
  profile clear;
  time = tic;
  feval(varargin{:});
  time = toc(time);
  profile report;
  profile off;
  fprintf('Profiling is done in %.2f seconds.\n', time);
end
