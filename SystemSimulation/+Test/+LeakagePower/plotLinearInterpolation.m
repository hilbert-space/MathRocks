function plotLinearInterpolation(varargin)
  assess('leakageOptions', Options( ...
    'method', 'Interpolation.Linear'), varargin{:});
end
