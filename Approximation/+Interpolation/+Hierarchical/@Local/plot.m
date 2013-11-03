function plot(this, output)
  nodes = this.basis.computeNodes(output.levels, output.orders);
  levelNodeCount = output.levelNodeCount;

  mapping = zeros(sum(levelNodeCount), 1);

  k = 0;
  for i = 1:length(levelNodeCount)
    mapping((k + 1):(k + levelNodeCount(i))) = i;
    k = k + levelNodeCount(i);
  end

  %
  % NOTE: Regarding the indexes, the drawing is inefficient as there are
  % a lot of overlaps (many nodes correspond to the same set of levels).
  %
  plot@Interpolation.Hierarchical.Base(this, ...
    'nodes', nodes, 'nodeMapping', mapping, ...
    'indexes', output.levels, 'indexMapping', mapping);
end
