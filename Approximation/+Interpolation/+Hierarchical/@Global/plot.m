function plot(this, output)
  nodes = this.basis.computeNodes(output.indexes);
  plot@Interpolation.Hierarchical.Base(this, nodes);
end
