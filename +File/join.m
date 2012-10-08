function path = join(varargin)
  path = varargin{1};
  for i = 2:length(varargin)
    path = [ path, filesep, varargin{i} ];
  end
end
