classdef Quadrature < handle
  properties (SetAccess = 'private')
    dimension

    points
    nodes
    weights
  end

  methods
    function this = Quadrature(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end

    function result = integrate(this, f)
      values = eval(f, this.nodes);
      codimension = size(values, 1);
      result = sum(Utils.replicate(this.weights, codimension, 1) .* values, 2);
    end
  end

  methods (Access = 'private')
    [ nodes, weights ] = constructTensor(this, options)
    [ nodes, weights ] = constructSparse(this, options)

    function initialize(this, options)
      this.dimension = options.dimension;

      filename = [ class(this), '_', ...
        DataHash(Utils.toString(options)), '.mat' ];

      if File.exist(filename)
        load(filename);
      else
        switch lower(options.method)
        case 'tensor'
          [ nodes, weights ] = this.constructTensor(options);
        case 'sparse'
          [ nodes, weights ] = this.constructSparse(options);
        otherwise
          error('The construction method is unknown.');
        end
        save(filename, 'nodes', 'weights', '-v7.3');
      end

      this.points = length(weights);
      this.nodes = nodes;
      this.weights = weights;
    end
  end
end
