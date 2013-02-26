function values = data(localData, globalData, values)
  if nargin < 3, values = jet; end

  count = size(values, 1);

  lMin = min(localData(:));
  lMax = max(localData(:));

  gMin = min(globalData(:));
  gMax = max(globalData(:));

  lower = floor(count * (lMin - gMin) / (gMax - gMin));
  upper = floor(count * (gMax - lMax) / (gMax - gMin));

  if lower < 0
    values = [ 0 0 0; values ];
    count = count + 1;
    lower = 0;
  end

  if upper < 0
    values = [ values; 1 1 1 ];
    count = count + 1;
    upper = 0;
  end

  values = values((1 + lower):(end - upper), :);

  colormap(values);
end
