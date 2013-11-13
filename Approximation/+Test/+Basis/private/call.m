function result = call(basis, method, varargin)
  options = Options(varargin{:});
  result = Utils.instantiate(String.join('.', 'Test', ...
    class(basis), method), basis, options);
end
