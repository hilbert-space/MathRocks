function plot(this, output)
  nodes = this.basis.computeNodes(output.indexes);
  plot@StochasticCollocation.Base(this, nodes);
end
