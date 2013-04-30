function display(this)
  stats = this.stats;

  fprintf('Leakage model:\n');
  fprintf('  L order: %d\n', stats.Lorder);
  fprintf('  T order: %d\n', stats.Torder);
  fprintf('  Log-scale formula with normalized L and T:\n')

  for i = 0:stats.Lorder
    for j = 0:stats.Torder
      fprintf('    %10.2e * %10.2e * Ln^%d * Tn^%d +\n', ...
        stats.scale(i + 1, j + 1), ...
        stats.coefficients(i + 1, j + 1), i, j);
    end
  end

  fprintf('  Ln = (L - %10.2e) / %10.2e\n', ...
    stats.expectation(1), stats.deviation(1));
  fprintf('  Tn = (T - %10.2e) / %10.2e\n', ...
    stats.expectation(2), stats.deviation(2));
end
