function string = join(separator, varargin)
  chunks = Utils.flatten(varargin{:});
  string = '';
  for i = 1:length(chunks)
    if i > 1, string = [ string, separator ]; end
    string = [ string, String(chunks{i}) ];
  end
end
