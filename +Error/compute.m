function error = compute(type, varargin)
  error = Error.(['compute', type])(varargin{:});
end
