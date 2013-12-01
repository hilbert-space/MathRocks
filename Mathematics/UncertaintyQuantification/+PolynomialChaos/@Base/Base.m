classdef Base < handle
  properties (SetAccess = 'protected')
    distribution

    inputCount
    order

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
      options = Options(varargin{:});
      this.distribution = options.distribution;

      this.inputCount = options.inputCount;
      this.order = options.order;

      filename = File.temporal([ String.join('_', ...
        class(this), DataHash(String(options))), '.mat' ]);

      if exist(filename, 'file')
        load(filename);
      else
        [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
          this.prepare(this.inputCount, this.order, options);
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

    function output = construct(this, f, varargin)
      output.coefficients = this.projection * f(this.nodes, varargin{:});
    end

    function stats = analyze(this, output)
      stats.expectation = output.coefficients(1, :);
      stats.variance = sum(output.coefficients(2:end, :).^2 .* ...
        repmat(this.norm(2:end), [ 1, size(output.coefficients, 2) ]), 1);
    end

    function data = sample(this, output, sampleCount)
      data = this.distribution.sample(sampleCount, this.inputCount);
      data = this.evaluate(output, data);
    end

    function display(this, varargin)
      options = Options( ...
        'inputCount', this.inputCount, ...
        'polynomialOrder', this.order, ...
        'polynomialTermCount', this.termCount, ...
        'quadratureNodeCount', this.nodeCount);
      display(options, class(this));
    end
  end

  methods (Abstract, Access = 'protected')
    basis = constructBasis(this, x, order)
    [ nodes, weights ] = constructQuadrature(this, options)
    norm = computeNormalizationConstant(this, index)
  end

  methods (Access = 'private')
    [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
      prepare(this, inputCount, order, varargin)
  end
end
