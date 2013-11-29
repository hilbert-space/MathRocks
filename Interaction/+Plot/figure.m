function h = figure(varargin)
  width = 800;
  height = 500;

  switch length(varargin)
  case 0
  case 1
    width = varargin{1};
    if ~isscalar(width)
      height = width(2);
      width = width(1);
    end
  case 2
    width = varargin{1};
    height = varargin{2};
  otherwise
    assert(false);
  end

  screen = get(0, 'ScreenSize');
  x = ceil((screen(3) - width) / 2);
  y = ceil((screen(4) - height) / 2);

  h = figure('Position', [ x, y, width, height ]);
end
