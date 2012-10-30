classdef Base < handle
  properties (SetAccess = 'protected')
    %
    % The stochastic (input) dimension.
    %
    inputCount

    %
    % The output dimension.
    %
    outputCount

    %
    % The maximal total order of the multivariate polynomials.
    %
    order

    %
    % The expectation and variance.
    %
    expectation
    variance
  end

  properties (Access = 'protected')
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
    function this = Base(f, varargin)
      options = Options('method', 'totalOrder', varargin{:});
      this.configure(options);
      this.construct(f, options);
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
    [ nodes, norm, projectionMatrix, rvPower, rvMap ] = prepare(this, options)

    function construct(this, f, options)
      this.inputCount = options.inputCount;
      this.outputCount = options.outputCount;
      this.order = options.order;

      filename = [ class(this), '_', ...
        DataHash(string(options)), '.mat' ];

      if exist(filename, 'file')
        load(filename);
      else
        [ nodes, norm, projectionMatrix, rvPower, rvMap ] = this.prepare(options);
        save(filename, 'nodes', 'norm', 'projectionMatrix', ...
          'rvPower', 'rvMap', '-v7.3');
      end

      %
      % Now, we expand the given function and compute its statistics.
      %
      coefficients = projectionMatrix * f(nodes);
      expectation = coefficients(1, :);
      variance = sum(coefficients(2:end, :).^2 .* ...
        Utils.replicate(norm(2:end), 1, this.outputCount), 1);

      %
      % Save.
      %
      this.rvPower = rvPower;
      this.rvMap = rvMap;

      this.coefficients = coefficients;

      this.expectation = expectation;
      this.variance = variance;
    end
  end
end
