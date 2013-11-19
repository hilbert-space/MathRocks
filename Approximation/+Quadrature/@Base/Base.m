classdef Base < handle
  properties (SetAccess = 'private')
    distribution

    dimensionCount
    level
    growth

    nodes
    weights
    nodeCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.distribution = options.distribution;

      this.dimensionCount = options.get('dimensionCount', 1);
      this.level = options.level;
      this.growth = options.get('growth', []);

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if File.exist(filename)
        load(filename);
      elseif this.dimensionCount == 1
        [ nodes, weights ] = this.rule(this.level);
        save(filename, 'nodes', 'weights', '-v7.3');
      else
        switch lower(options.get('method', 'adaptive'))
        case 'adaptive'
          [ nodes, weights ] = this.constructAdaptive( ...
            this.dimensionCount, this.level);
        case 'tensor'
          [ nodes, weights ] = this.constructTensor( ...
            this.dimensionCount, this.level);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse( ...
            this.dimensionCount, this.level);
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

  methods (Abstract, Access = 'protected')
    [ nodes, weights ] = rule(this, level)
  end

  methods (Access = 'private')
    function [ nodes, weights ] = constructAdaptive( ...
        this, dimensionCount, level)

      [ nodes, weights ] = this.constructSparse(dimensionCount, level);
      sparseNodeCount = length(weights);

      order = numel(this.rule(level));
      tensorNodeCount = order^dimensionCount;

      if sparseNodeCount <= tensorNodeCount, return; end

      [ nodes, weights ] = this.constructTensor(dimensionCount, level);
    end

    function [ nodes, weights ] = constructTensor( ...
      this, dimensionCount, level)

      [ nodes, weights ] = this.rule(level);
      nodes = Utils.tensor(repmat({ nodes }, 1, dimensionCount));
      weights = prod(Utils.tensor( ...
        repmat({ weights }, 1, dimensionCount)), 2);
    end

    function [ nodes, weights ] = constructSparse( ...
      this, dimensionCount, level)

      compute = @(level) this.rule(level);
      [ nodes, weights ] = Utils.smolyak( ...
        dimensionCount, compute, level);
    end
  end
end
