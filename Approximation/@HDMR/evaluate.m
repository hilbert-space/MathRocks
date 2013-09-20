function values = evaluate(this, nodes)
  planeNodes = nodes(:);
  assert(all(planeNodes >= 0) && all(planeNodes <= 1));

  interpolants = this.interpolants;
  inputCount = this.inputCount;

  assert(inputCount == size(nodes, 2));

  nodeCount = size(nodes, 1);

  offset = repmat(this.offset, [ nodeCount, 1 ]);

  interpolantCount = length(interpolants);

  keys = interpolants.keys;
  index = cell(interpolantCount, 1);
  order = zeros(interpolantCount, 1);

  %
  % Precompute all the interpolants in the given nodes.
  %
  valueCache = containers.Map;
  for i = 1:interpolantCount
    index{i} = uint16(keys{i});
    order(i) = length(index{i});
    valueCache(keys{i}) = interpolants(keys{i}).evaluate(nodes(:, index{i}));
  end

  %
  % Now, we need to combine the computed values, and we begin with
  % the zero-order interpolant.
  %
  values = offset;
  for i = 1:interpolantCount
    %
    % The value of the current interpolant.
    %
    values = values + valueCache(keys{i});

    %
    % The zero-order interpolant.
    %
    values = values + (-1)^(order(i) - 0) * offset;

    %
    % The rest of the low-order interpolants.
    %
    lowKeys = selectLowKeys(interpolants, order(i), index{i});
    for j = 1:length(lowKeys)
      values = values + ...
        (-1)^(order(i) - length(lowKeys{j})) * ...
          valueCache(lowKeys{j});
    end
  end
end
