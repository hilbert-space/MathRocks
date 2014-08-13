function LinearInterpolation(varargin)
  assess('leakageOptions', Options( ...
    'method', 'Interpolation', 'basis', 'Linear'), varargin{:});
end
