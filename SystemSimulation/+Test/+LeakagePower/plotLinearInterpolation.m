function plotLinearInterpolation(varargin)
  assess('processParameters', { 'L' }, 'leakageOptions', Options( ...
    'method', 'Interpolation.Linear'), varargin{:});
end
