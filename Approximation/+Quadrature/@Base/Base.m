classdef Base < handle
  properties (SetAccess = 'private')
    dimensionCount
    level
    nodes
    weights
    nodeCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.dimensionCount = options.get('dimensionCount', 1);
      this.level = options.level;

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if File.exist(filename)
        load(filename);
      elseif this.dimensionCount == 1
        [ nodes, weights ] = this.rule(this.level, options);
        save(filename, 'nodes', 'weights', '-v7.3');
      else
        switch lower(options.get('method', 'adaptive'))
        case 'adaptive'
          [ nodes, weights ] = this.constructAdaptive( ...
            this.dimensionCount, this.level, options);
        case 'tensor'
          [ nodes, weights ] = this.constructTensor( ...
            this.dimensionCount, this.level, options);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse( ...
            this.dimensionCount, this.level, options);
        otherwise
          assert('false');
        end
        save(filename, 'nodes', 'weights', '-v7.3');
      end

      this.nodes = nodes;
      this.weights = weights;
      this.nodeCount = length(weights);
    end
  end

  methods (Access = 'protected')
    [ nodes, weights ] = rule(this, level)
  end

  methods (Access = 'private')
    function [ nodes, weights ] = constructAdaptive( ...
      this, dimensionCount, level, options)

      [ nodes, weights ] = this.constructSparse( ...
        dimensionCount, level, options);
      sparseNodeCount = length(weights);

      order = size(this.rule(level, options), 1);
      tensorNodeCount = order^dimensionCount;

      if sparseNodeCount <= tensorNodeCount, return; end

      [ nodes, weights ] = this.constructTensor( ...
        dimensionCount, level, options);
    end

    function [ nodes, weights ] = constructTensor( ...
      this, dimensionCount, level, options)

      [ nodes, weights ] = this.rule(level, options);

      nodes = Utils.tensor(repmat({ nodes }, 1, dimensionCount));
      weights = prod(Utils.tensor(repmat({ weights }, 1, dimensionCount)), 2);
    end

    function [ nodes, weights ] = constructSparse( ...
      this, dimensionCount, level, options)

      compute = @(level) this.rule(level, options);

      [ nodes, weights ] = Utils.smolyak(dimensionCount, compute, level);
    end
  end
end
