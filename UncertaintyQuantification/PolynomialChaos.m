function surrogate = PolynomialChaos(varargin)
  options = Options(varargin{:});
  if options.has('basis')
    basis = options.basis;
  elseif options.has('distribution')
    basis = toBasis(options.distribution);
  else
    basis = 'Hermite';
  end
  surrogate = PolynomialChaos.(basis)(options);
end

function basis = toBasis(distribution)
  switch class(distribution)
  case 'ProbabilityDistribution.Gaussian'
    basis = 'Hermite';
  case 'ProbabilityDistribution.Uniform'
    basis = 'Legendre';
  case 'ProbabilityDistribution.Beta'
    basis = 'Jacobi';
  otherwise
    assert(false);
  end
end