function compare(name, A, N)
  fprintf('%s:\n', name);
  fprintf('  Analytical: %10.8f (%s)\n', double(A), char(A));
  fprintf('  Numerical:  %10.8f\n', N);
  fprintf('  Delta:      %g\n', double(A) - N);
end
