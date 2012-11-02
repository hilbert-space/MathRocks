classdef Base < handle
  properties (SetAccess = 'protected')
    %
    % The stochastic (input) dimension.
    %
    inputCount

    %
    % The maximal total order of the multivariate polynomials.
    %
    order

    %
    % The expectation and variance.
    %
    expectation
    variance

    nodeCount
    termCount
  end

  properties (SetAccess = 'protected')
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

    %
    % The coefficients of the polynomial chaos expansion.
    %
    coefficients
  end

  methods
    function this = Base(varargin)
      if isa(varargin{1}, 'function_handle')
        f = varargin{1};
        options = Options('method', 'totalOrder', varargin{2:end});
      else
        f = [];
        options = Options('method', 'totalOrder', varargin{1:end});
      end

      this.configure(options);
      this.initialize(options);

      if ~isempty(f)
        this.expandPermanent(f);
      end
    end

    function new = expand(this, f, old)
      if nargin > 2
        new = this.projection * f(this.nodes, this.evaluation * old);
      else
        new = this.projection * f(this.nodes);
      end
    end
  end

  methods (Access = 'protected')
    function configure(this, options)
    end
  end

  methods (Abstract, Access = 'protected')
    basis = constructUnivariateBasis(this, x, order)
    [ nodes, weights ] = constructQuadrature(this, options)
    norm = computeNormalizationConstant(this, i, index)
  end

  methods (Access = 'private')
    basis = constructBasis(this, x, order, index)
    [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
      construct(this, options)

    function initialize(this, options)
      this.inputCount = options.inputCount;
      this.order = options.order;

      filename = [ class(this), '_', ...
        DataHash(Utils.toString(options)), '.mat' ];

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

    function expandPermanent(this, f)
      %
      % Now, we expand the given function and compute its statistics.
      %
      coefficients = this.projection * f(this.nodes);
      outputCount = size(coefficients, 2);

      this.coefficients = coefficients;
      this.expectation = coefficients(1, :);
      this.variance = sum(coefficients(2:end, :).^2 .* ...
        Utils.replicate(this.norm(2:end), 1, outputCount), 1);
    end
  end
end
