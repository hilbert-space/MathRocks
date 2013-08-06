function h = figure(width, height)
  if nargin < 2, height = 400; end
  if nargin < 1, width  = 600; end

  screen = get(0, 'ScreenSize');
  x = ceil((screen(3) - width) / 2);
  y = ceil((screen(4) - height) / 2);

  h = figure('Position', [ x, y, width, height ]);
end
