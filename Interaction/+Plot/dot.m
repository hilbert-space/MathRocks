function dot(varargin)
  for i = 1:length(varargin)
    varargin{i} = [ varargin{i}, varargin{i} ];
  end
  line(varargin{:}, 'Color', 'r', 'MarkerSize', 40, 'Marker', '.');
end
