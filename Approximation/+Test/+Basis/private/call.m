function result = call(basis, method, varargin)
  if isa(basis, 'Basis.Hat.Base')
    result = Utils.instantiate([ 'Test.Basis.Hat.', method ], ...
      basis, varargin{:});
  else
    assert(false);
  end
end
