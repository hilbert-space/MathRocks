function sparseGrid(nodes, mapping)
  [ nodeCount, dimensionCount ] = size(nodes);

  if nargin < 2, mapping = ones(nodeCount, 1); end
  assert(length(mapping) == nodeCount);

  levels = transpose(unique(mapping(:), 'sorted'));

  Plot.figure(600, 600);
  Plot.title('Sparse grid');

  switch dimensionCount
  case 1
    color = 'k';
    for i = levels
      if i == levels(end), color = 'r'; end
      I = mapping == i;
      Plot.line(nodes(I), i * ones(size(nnz(I), 1)), ...
        'discrete', true, 'style', { 'MarkerFaceColor', color });
    end
  case 2
    I = mapping ~= levels(end);
    Plot.line(nodes(I, 1), nodes(I, 2), ...
      'discrete', true, 'style', { 'MarkerFaceColor', 'k' });
    I = mapping == levels(end);
    Plot.line(nodes(I, 1), nodes(I, 2), ...
      'discrete', true, 'style', { 'MarkerFaceColor', 'r' });
  case 3
    I = mapping ~= levels(end);
    Plot.line({ nodes(I, 1), nodes(I, 2) }, nodes(I, 3), ...
      'discrete', true, 'style', { 'MarkerFaceColor', 'k' });
    I = mapping == levels(end);
    Plot.line({ nodes(I, 1), nodes(I, 2) }, nodes(I, 3), ...
      'discrete', true, 'style', { 'MarkerFaceColor', 'r' });
  otherwise
    assert(false);
  end
end
