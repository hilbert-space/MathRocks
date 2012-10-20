function display(this)
  fprintf('Polynomial chaos:\n');
  fprintf('  Input dimension:  %d\n', this.inputDimension);
  fprintf('  Output dimension: %d\n', this.outputDimension);
  fprintf('  Polynomial order: %d\n', this.order);
  fprintf('  Polynomial terms: %d\n', size(this.coefficients, 1));
  fprintf('  Monomial terms:   %d\n', size(this.rvPower, 1));
end
