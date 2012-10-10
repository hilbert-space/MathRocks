function Title(text, varargin)
  if length(varargin) > 0
    text = sprintf(text, varargin{:});
  end
  title(text, 'FontSize', 16);
end
