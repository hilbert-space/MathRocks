classdef Quadrature < handle
  properties (SetAccess = 'private')
    dimensionCount

    nodes
    weights
    nodeCount
  end

  methods
    function this = Quadrature(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end

    function result = integrate(this, f)
      values = feval(f, this.nodes);
      codimension = size(values, 1);
      result = sum(repmat(this.weights, [ codimension, 1 ]) .* values, 2);
    end
  end

  methods (Access = 'private')
    [ nodes, weights ] = constructTensor(this, options)
    [ nodes, weights ] = constructSparse(this, options)

    function initialize(this, options)
      this.dimensionCount = options.dimensionCount;

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if File.exist(filename)
        load(filename);
      else
        switch lower(options.method)
        case 'adaptive'
          [ nodes, weights ] = this.constructAdaptive(options);
        case 'tensor'
          [ nodes, weights ] = this.constructTensor(options);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse(options);
        otherwise
          error('The construction method is unknown.');
        end
        save(filename, 'nodes', 'weights', '-v7.3');
      end

      this.nodes = nodes;
      this.weights = weights;
      this.nodeCount = length(weights);
    end
  end
end
