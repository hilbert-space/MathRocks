classdef Base < handle
  properties (SetAccess = 'protected')
    %
    % The stochastic dimension.
    %
    dimension

    %
    % The deterministic dimension.
    %
    codimension

    %
    % The maximal total order of the multivariate polynomials.
    %
    order

    %
    % The normalization constants of each basis polynomial.
    %
    norm

    %
    % The probability distribution of the RVs.
    %
    distribution
  end

  properties (Access = 'protected')
    %
    % The nodes themselves.
    %
    nodes

    %
    % The projection matrix.
    %
    projectionMatrix

    %
    % The evaluation matrix.
    %
    evaluationMatrix

    %
    % A (dimension x monomial terms) matrix of the exponents
    % of each of the RVs in each of the monomials.
    %
    rvPower

    %
    % A (expansion terms x monomial terms) matrix that maps the PC expansion
    % coefficients to the coefficients of the monomials.
    %
    rvMap
  end

  methods
    function this = Base(varargin)
      options = Options('dimension', 1, ...
        'codimension', 1, 'method', 'totalOrder', varargin{:});

      this.initialize(options);
    end

    function next = expand(this, f, last)
      if nargin > 2
        next = f(this.nodes, last * this.evaluationMatrix) * this.projectionMatrix;
      else
        next = f(this.nodes) * this.projectionMatrix;
      end
    end
  end

  methods (Abstract, Access = 'protected')
    basis = constructUnivariateBasis(this, x, order)
    norm = computeNormalizationConstant(this, i, index)
  end

  methods (Access = 'private')
    basis = constructBasis(this, x, order, index)
    [ nodes, norm, projectionMatrix, evaluationMatrix, ...
      rvPower, rvMap ] = construct(this, options)

    function initialize(this, options)
      this.dimension = options.dimension;
      this.codimension = options.codimension;
      this.order = options.order;

      filename = [ class(this), '_', string(options), '.mat' ];

      if exist(filename, 'file')
        load(filename);
      else
        [ nodes, norm, projectionMatrix, evaluationMatrix, ...
          rvPower, rvMap ] = this.construct(options);

        save(filename, 'nodes', 'norm', 'projectionMatrix', ...
          'evaluationMatrix', 'rvPower', 'rvMap', '-v7.3');
      end

      this.nodes = nodes;
      this.norm = norm;
      this.projectionMatrix = projectionMatrix;
      this.evaluationMatrix = evaluationMatrix;
      this.rvPower = rvPower;
      this.rvMap = rvMap;
    end
  end
end
