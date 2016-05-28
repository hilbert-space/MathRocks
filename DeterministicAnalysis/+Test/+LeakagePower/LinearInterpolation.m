function LinearInterpolation(varargin)
  setup;
  assess('leakageOptions', Options( ...
    'method', 'Interpolation', 'basis', 'Linear'), varargin{:});
end
