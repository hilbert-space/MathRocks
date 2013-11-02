function plot(~, nodes, mapping)
  [ nodeCount, inputCount ] = size(nodes);

  if nargin < 3, mapping = ones(nodeCount, 1); end
  assert(length(mapping) == nodeCount);

  levels = transpose(unique(mapping(:), 'sorted'));

  Plot.figure(600, 600);
  Plot.title('Interpolation grid');

  style = @(color) { 'MarkerSize', 5, 'MarkerFaceColor', color, ...
    'MarkerEdgeColor', color };

  switch inputCount
  case 1
    color = 'k';
    for i = levels
      if i == levels(end), color = 'r'; end
      I = mapping == i;
      Plot.line(nodes(I), i * ones(size(nnz(I), 1)), ...
        'discrete', true, 'style', style(color));
    end
  case 2
    I = mapping ~= levels(end);
    Plot.line(nodes(I, 1), nodes(I, 2), ...
      'discrete', true, 'style', style('k'));
    I = mapping == levels(end);
    Plot.line(nodes(I, 1), nodes(I, 2), ...
      'discrete', true, 'style', style('r'));
  case 3
    I = mapping ~= levels(end);
    Plot.line({ nodes(I, 1), nodes(I, 2) }, nodes(I, 3), ...
      'discrete', true, 'style', style('k'));
    I = mapping == levels(end);
    Plot.line({ nodes(I, 1), nodes(I, 2) }, nodes(I, 3), ...
      'discrete', true, 'style', style('r'));
    view(-45, 45);
  otherwise
    assert(false);
  end
end
