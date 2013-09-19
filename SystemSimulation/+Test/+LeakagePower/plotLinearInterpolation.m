function plotLinearInterpolation(varargin)
  assess('leakageOptions', ...
    Options('fittingMethod', 'Interpolation.Linear'), varargin{:});
end
