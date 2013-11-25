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
      options = Options('dimensionCount', 1, ...
        'growth', 'slow-linear', varargin{:});
      this.distribution = options.distribution;

      this.dimensionCount = options.dimensionCount;
      this.level = options.level;
      this.growth = options.growth;

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if File.exist(filename)
        load(filename);
      else
        switch lower(options.get('method', 'minimal'))
        case 'minimal'
          [ nodes, weights ] = this.constructMinimal(options);
        case 'tensor'
          [ nodes, weights ] = this.constructTensor(options);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse(options);
        otherwise
          assert('false');
        end
        save(filename, 'nodes', 'weights', '-v7.3');
      end

      this.nodes = nodes;
      this.weights = weights;
      this.nodeCount = numel(weights);
    end
  end

  methods (Abstract, Access = 'protected')
    [ nodes, weights ] = rule(this, order)
  end

  methods (Access = 'protected')
    function order = computeOrder(this, level)
      %
      % Reference:
      %
      % http://people.sc.fsu.edu/~jburkardt/m_src/sgmga/sgmga.html
      %
      if isa(this.growth, 'function_handle')
        order = feval(this.growth, level);
      elseif strcmpi(this.growth, 'slow-linear')
        order = level + 1;
      elseif strcmpi(this.growth, 'full-exponential')
        order = 2^(level + 1) - 1;
      else
        assert(false);
      end
    end
  end

  methods (Access = 'private')
    function [ nodes, weights ] = constructMinimal(this, options)
      [ nodes, weights ] = this.constructSparse(options);

      tensorNodeCount = this.computeOrder(options.level)^options.dimensionCount;
      if numel(weights) <= tensorNodeCount, return; end

      [ nodes, weights ] = this.constructTensor(options);
    end

    function [ nodes, weights ] = constructTensor(this, options)
      [ nodes, weights ] = Quadrature.tensor(options.dimensionCount, ...
        @(level) this.rule(this.computeOrder(level)), options.level);
    end

    function [ nodes, weights ] = constructSparse(this, options)
      [ nodes, weights ] = Quadrature.smolyak(options.dimensionCount, ...
        @(level) this.rule(this.computeOrder(level)), options.level, ...
        options.get('anisotropy', []));
    end
  end
end
