function assessCrossIntegral(varargin)
  options = Options(varargin{:});

  basis = instantiate(options);

  compare('Integral of the product of two basis functions', ...
    call(basis, 'deriveCrossIntegral', options), ...
    call(basis, 'estimateCrossIntegral', options));
end
