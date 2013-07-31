function Title(varargin)
  if isa(varargin{1}, 'double')
    h = varargin{1};
    varargin(1) = [];
  else
    h = gcf;
  end

  text = sprintf(varargin{:});
  title(get(h, 'CurrentAxes'), text, 'FontSize', 16);
  set(h, 'name', text);
end
