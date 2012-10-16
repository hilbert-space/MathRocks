function display(this)
  fprintf('Polynomial chaos:\n');
  fprintf('  Stochastic dimension:        %d\n', this.dimension);
  fprintf('  Deterministic dimension:     %d\n', this.codimension);
  fprintf('  Polynomial order:            %d\n', this.order);
  fprintf('  Polynomial terms:            %d\n', size(this.projectionMatrix, 1));
  fprintf('  Monomial terms:              %d\n', size(this.rvPower, 1));
  fprintf('  Number of integration nodes: %d\n', size(this.nodes, 1));
end
