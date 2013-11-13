function LinearInterpolation(varargin)
  assess('leakageOptions', Options('dependency', 'Nonlinear', ...
    'method', 'Interpolation', 'basis', 'Linear'), varargin{:});
end
