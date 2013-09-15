function object = instantiate(name, varargin)
  object = eval([ name, '(varargin{:})' ]);
end
