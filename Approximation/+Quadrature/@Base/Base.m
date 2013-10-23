classdef Base < handle
  properties (SetAccess = 'private')
    order
    dimensionCount
    nodes
    weights
    nodeCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.order = options.order;
      this.dimensionCount = options.dimensionCount;

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if File.exist(filename)
        load(filename);
      else
        switch lower(options.get('method', 'adaptive'))
        case 'adaptive'
          [ nodes, weights ] = this.constructAdaptive( ...
            this.order, this.dimensionCount, options);
        case 'tensor'
          [ nodes, weights ] = this.constructTensor( ...
            this.order, this.dimensionCount, options);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse( ...
            this.order, this.dimensionCount, options);
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
    [ nodes, weights ] = rule(this, order)
  end

  methods (Access = 'private')
    function [ nodes, weights ] = constructAdaptive( ...
      this, order, dimensionCount, options)

      [ nodes, weights ] = this.constructSparse( ...
        order, dimensionCount, options);

      sparseNodeCount = length(weights);
      tensorNodeCount = order^dimensionCount;

      if sparseNodeCount <= tensorNodeCount, return; end

      [ nodes, weights ] = this.constructTensor( ...
        order, dimensionCount, options);
    end

    function [ nodes, weights ] = constructTensor( ...
      this, order, dimensionCount, options)

      [ nodes, weights ] = this.rule(order, options);

      nodes = Utils.tensor(repmat({ nodes }, 1, dimensionCount));
      weights = prod(Utils.tensor(repmat({ weights }, 1, dimensionCount)), 2);
    end

    function [ nodes, weights ] = constructSparse( ...
      this, order, dimensionCount, options)

      compute = @(order) this.rule(order, options);

      [ nodes, weights ] = Utils.smolyak(compute, order, dimensionCount);
    end
  end
end
