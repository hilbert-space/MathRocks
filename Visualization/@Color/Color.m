classdef Color < handle
  properties (Constant)
    palette = { ...
      [ 87, 181, 232] / 255, ...
      [ 230, 158, 0 ] / 255, ...
      [ 129, 197, 122 ] / 255, ...
      [ 20, 43, 140 ] / 255, ...
      [ 195, 0, 191 ] / 255 ...
    };
  end

  methods (Static)
    values = map(localData, globalMin, globalMax)

    function color = pick(i)
      if nargin == 0, i = randi(10); end
      palette = Color.palette;
      color = palette{mod(i - 1, length(palette)) + 1};
    end
  end
end
