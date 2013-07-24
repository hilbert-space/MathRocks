function display(this)
  output = this.output;

  fprintf('Leakage model:\n');
  fprintf('  L order: %d\n', output.Lorder);
  fprintf('  T order: %d\n', output.Torder);
  fprintf('  Normalized polynomial:\n')

  for i = 0:output.Lorder
    for j = 0:output.Torder
      fprintf('    %10.2e * Ln^%d * Tn^%d +\n', ...
        output.coefficients(i + 1, j + 1), i, j);
    end
  end

  fprintf('  Ln = (L - %10.2e) / %10.2e\n', ...
    output.expectation(1), output.deviation(1));
  fprintf('  Tn = (T - %10.2e) / %10.2e\n', ...
    output.expectation(2), output.deviation(2));
end
