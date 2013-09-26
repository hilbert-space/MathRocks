function path = join(varargin)
  path = String.join(filesep, varargin{:});
end
