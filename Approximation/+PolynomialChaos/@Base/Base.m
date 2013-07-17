classdef Base < handle
  properties (SetAccess = 'protected')
    order

    inputCount
    nodeCount
    termCount

    nodes
    norm
    projection
    evaluation

    %
    % A (# of monomial terms) x (# of stochastic dimension) matrix
    % of the exponents of each of the RVs in each of the monomials.
    %
    rvPower

    %
    % A (# of monomial terms) x (# of polynomial terms) matrix that
    % maps the PC expansion coefficients to the coefficients of
    % the monomials.
    %
    rvMap
  end

  methods
    function this = Base(varargin)
      options = Options('method', 'totalOrder', varargin{:});
      this.initialize(options);
    end

    function output = expand(this, f, varargin)
      coefficients = this.projection * f(this.nodes, varargin{:});

      output.expectation = coefficients(1, :);
      output.variance = sum(coefficients(2:end, :).^2 .* ...
        repmat(this.norm(2:end), [ 1, size(coefficients, 2) ]), 1);
      output.coefficients = coefficients;
    end

    function display(this)
      options = Options( ...
        'Input dimension', this.inputCount, ...
        'Polynomial order', this.order, ...
        'Polynomial terms', this.termCount, ...
        'Monomial terms', size(this.rvPower, 1), ...
        'Quadrature nodes', this.nodeCount);
      display(options, 'Polynomial chaos');
    end
  end

  methods (Access = 'protected')
    function initialize(this, options)
      this.order = options.order;
      this.inputCount = options.inputCount;

      filename = File.temporal([ class(this), '_', ...
        DataHash(Utils.toString(options)), '.mat' ]);

      if exist(filename, 'file')
        load(filename);
      else
        [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
          this.construct(options);
        save(filename, 'nodes', 'norm', 'projection', 'evaluation', ...
          'rvPower', 'rvMap', '-v7.3');
      end

      this.nodeCount = size(nodes, 1);
      this.termCount = size(rvMap, 2);

      this.nodes = nodes;
      this.norm = norm;
      this.projection = projection;
      this.evaluation = evaluation;
      this.rvPower = rvPower;
      this.rvMap = rvMap;
    end
  end

  methods (Abstract, Access = 'protected')
    basis = constructUnivariateBasis(this, x, order)
    [ nodes, weights ] = constructQuadrature(this, options)
    norm = computeNormalizationConstant(this, i, index)
  end

  methods (Abstract)
    data = sample(this, output, sampleCount)
  end

  methods (Access = 'private')
    basis = constructBasis(this, x, order, index)
    [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
      construct(this, options)
  end
end
