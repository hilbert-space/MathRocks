function plot(this, output)
  nodes = this.basis.computeNodes(output.indexes);
  plot@SparseGridInterpolation.Base(this, nodes);
end
