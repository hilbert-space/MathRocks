function compare(name, analytical, numerical)
  fprintf('%s:\n', name);
  if isnan(numerical)
    fprintf('  Analytical: %s\n', char(analytical));
  else
    fprintf('  Analytical: %10.8f (%s)\n', ...
      double(analytical), char(analytical));
    fprintf('  Numerical:  %10.8f\n', numerical);
    fprintf('  Delta:      %g\n', ...
      double(analytical) - numerical);
  end
end
