function Title(varargin)
  if isa(varargin{1}, 'double')
    h = varargin{1};
    varargin(1) = [];
  else
    h = gcf;
  end

  h = get(h, 'CurrentAxes');
  if isempty(h), h = gca; end

  text = sprintf(varargin{:});
  title(h, text, 'FontSize', 16);
end
