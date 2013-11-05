function path = library(varargin)
  path = File.join(fileparts(File.trace), varargin{:});
end
