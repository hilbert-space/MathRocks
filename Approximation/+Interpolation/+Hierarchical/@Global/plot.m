function plot(this, output)
  [nodes, offsets, counts] = this.basis.computeNodes(output.indexes);

  mapping = zeros(size(nodes, 1), 1);

  for i = 1:size(offsets, 1)
    mapping((offsets(i) + 1):(offsets(i) + counts(i))) = i;
  end

  plot@Interpolation.Hierarchical.Base(this, ...
    'nodes', nodes, 'nodeMapping', mapping, ...
    'indexes', output.indexes, 'indexMapping', 1:size(offsets, 1));
end
