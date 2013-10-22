function plot(this, output)
  nodes = this.basis.computeNodes(output.indexes);
  plot@SparseGrid.Base(this, nodes);
  Plot.title('Dimension-adaptive sparse grid');
end
