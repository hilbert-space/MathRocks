function construct(this, f, options)
  dimensionCount = 2;
  tolerance = 1e-3;
  maxLevel = 5;

  %
  % The first two levels.
  %
  indexI = ones(1 + dimensionCount, dimensionCount, 'uint8');
  indexJ = ones(1 + 2 * dimensionCount, dimensionCount, 'uint8');
  nodes = 0.5 * ones(1 + 2 * dimensionCount, dimensionCount);
  mappingI = ones(1 + 2 * dimensionCount, 1, 'uint8');

  %
  % One node is already in place.
  %
  nodeCount = 1;

  for i = 1:dimensionCount
    indexI(1 + i, i) = 2;

    %
    % The left most.
    %
    nodeCount = nodeCount + 1;

    indexJ(nodeCount, i) = 1;
    nodes(nodeCount, i) = 0.0;
    mappingI(nodeCount) = 1 + i;

    %
    % The right most.
    %
    nodeCount = nodeCount + 1;

    indexJ(nodeCount, i) = 3;
    nodes(nodeCount, i) = 1.0;
    mappingI(nodeCount) = 1 + i;
  end

  mappingI(2:end) = 2;

  %
  % Evaluate the functions on the first two levels.
  %
  values = f(nodes);

  passiveCount = 1;
  activeCount = 2 * dimensionCount;

  %
  % The other levels.
  %
  level = 3;
  while level <= maxLevel
    %
    % NOTE: We skip the first one since it represents the very first level
    % where all the basis functions are equal to one.
    %
    passiveNodes = nodes(2:passiveCount, :);
    passiveIntervals = double(2.^(indexI(mappingI(2:passiveCount), :) - 1));
    activeIntervals = double(2^(level - 1));

    %
    % NOTE: When we go from the second level to the third one
    % there is only one child; otherwise, two.
    %
    childrenCount = (level == 3) + 2 * (level > 3);

    %
    % Evaluate the interpolant, which was constructed on the passive points,
    % at the active points.
    %
    increasedI = zeros(size(indexI), 'uint8');
    for i = (passiveCount + 1):(passiveCount + activeCount)
      delta = abs(repmat(nodes(i, :), passiveCount - 1, 1) - passiveNodes);
      mask = delta < 1 ./ passiveIntervals;
      basis = [ 1; prod((1 - passiveIntervals .* delta) .* mask, 2) ];
      surplus = abs(values(i) - sum(values(1:passiveCount) .* basis));

      if surplus > tolerance
        %
        % The threshold is violated; hence, we need to add all
        % the neigbors, and the neighbors are almost the same as
        % the current node except a small change.
        %

        iIndexI = mappingI(i);

        indexJ = [ indexJ; ...
          zeros(childrenCount * dimensionCount, dimensionCount, 'uint8') ];

        nodes = [ nodes; ...
          zeros(childrenCount * dimensionCount, dimensionCount) ];

        mappingI = [ mappingI; ...
          zeros(childrenCount * dimensionCount, 1, 'uint8') ];

        for j = 1:dimensionCount
          %
          % Add a new i-index if needed.
          %
          if increasedI(iIndexI, j) == 0
            increasedI(iIndexI, j) = size(indexI, 1) + 1;
            indexI = [ indexI; indexI(iIndexI, :) ];
            indexI(end, j) = indexI(end, j) + 1;
          end

          %
          % The left one.
          %
          nodeCount = nodeCount + 1;

          indexJ(nodeCount, :) = indexJ(i, :);
          if childrenCount > 1
            indexJ(nodeCount, j) = 2 * indexJ(i, j) - 2;
          else
            %
            % NOTE: Once again, there is one special case when we
            % go from the second level to the third one.
            %
            switch indexJ(i, j)
            case 1
              indexJ(nodeCount, j) = 2;
            case 3
              indexJ(nodeCount, j) = 4;
            otherwise
              assert(false);
            end
          end

          nodes(nodeCount, :) = nodes(i, :);
          nodes(nodeCount, j) = ...
            double(indexJ(nodeCount, j) - 1) / activeIntervals;

          mappingI(nodeCount) = increasedI(iIndexI, j);

          if childrenCount == 1, continue; end

          %
          % The right one.
          %
          nodeCount = nodeCount + 1;

          indexJ(nodeCount, :) = indexJ(i, :);
          indexJ(nodeCount, j) = 2 * indexJ(i, j);

          nodes(nodeCount, :) = nodes(i, :);
          nodes(nodeCount, j) = ...
            double(indexJ(nodeCount, j) - 1) / activeIntervals;

          mappingI(nodeCount) = increasedI(iIndexI, j);
        end
      end
    end

    activeCount = nodeCount - passiveCount - activeCount;

    if activeCount == 0, break; end

    passiveCount = nodeCount - activeCount;

    %
    % Compute the function in the new points.
    %
    values = [ values; f(nodes((passiveCount + 1):end, :)) ];

    level = level + 1;
  end

  this.nodes = nodes;
end

function [ nodes, J ] = computeNodes(i)
  if i == 1
    J = uint8([ 1 ]);
    nodes = [ 0.5 ];
  elseif i == 2
    J = uint8([ 1; 3 ]);
    nodes = [ 0.0; 1.0 ];
  else
    count = 2^(i - 1) + 1;
    J = transpose(uint8(2:2:(count - 1)));
    nodes = (J - 1) / (count - 1);
  end
end
