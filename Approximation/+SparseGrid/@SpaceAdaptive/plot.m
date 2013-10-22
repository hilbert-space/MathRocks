function plot(this, output)
  nodes = this.basis.computeNodes(output.levels, output.orders);
  levelNodeCount = output.levelNodeCount;

  mapping = zeros(sum(levelNodeCount), 1);

  k = 0;
  for i = 1:length(levelNodeCount)
    mapping((k + 1):(k + levelNodeCount(i))) = i;
    k = k + levelNodeCount(i);
  end

  plot@SparseGrid.Base(this, nodes, mapping);
  Plot.title('Space-adaptive sparse grid');
end
