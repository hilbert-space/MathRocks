function plot(this)
  nodes = this.nodes;
  nodeCount = this.nodeCount;
  levelNodeCount = this.levelNodeCount;

  switch this.inputDimension
  case 1
    k = 1;
    for level = 1:this.level
      x = nodes(k:(k + levelNodeCount(level) - 1));
      k = k + levelNodeCount(level);
      line(x, level * ones(size(x)), ...
        'Marker', '.', 'MarkerSize', 10, ...
        'Color', [ 1 1 1 ] / 6, 'LineStyle', 'None');
    end

    ylim([ 0, this.level ]);
  case 2
    lastNodeCount = levelNodeCount(end);

    line( ...
      nodes(1:(nodeCount - lastNodeCount), 1), ...
      nodes(1:(nodeCount - lastNodeCount), 2), ...
      'Marker', '.', 'MarkerSize', 10, ...
      'Color', [ 1 1 1 ] / 6, 'LineStyle', 'None');

    if lastNodeCount == 0, return; end

    line( ...
      nodes((nodeCount - lastNodeCount + 1):end, 1), ...
      nodes((nodeCount - lastNodeCount + 1):end, 2), ...
      'Marker', '.', 'MarkerSize', 10, ...
      'Color', 'r', 'LineStyle', 'None');
  otherwise
    error('Only one- and two-dimensional grids are supported.');
  end
end
