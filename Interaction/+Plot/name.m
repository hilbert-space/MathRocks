function name(text, varargin)
  if length(varargin) > 0
    text = sprintf(text, varargin{:});
  end
  set(gcf, 'name', text);
end
