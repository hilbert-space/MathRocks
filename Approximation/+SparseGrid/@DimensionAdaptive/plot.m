function plot(this, output)
  nodes = this.basis.computeNodes(output.indexes);
  Plot.sparseGrid(nodes);
  Plot.title('Dimension-adaptive sparse grid');
end
