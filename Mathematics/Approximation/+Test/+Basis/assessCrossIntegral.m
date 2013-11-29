function assessCrossIntegral(varargin)
  options = Options(varargin{:});

  basis = Basis(options);

  compare('Integral of the product of two basis functions', ...
    call(basis, 'deriveCrossIntegral', options), ...
    call(basis, 'estimateCrossIntegral', options));
end
