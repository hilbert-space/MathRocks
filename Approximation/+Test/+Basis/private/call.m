function result = call(basis, method, varargin)
  if isa(basis, 'Basis.Base.NewtonCotesHat')
    result = Utils.instantiate([ 'Test.Basis.NewtonCotesHat.', method ], ...
      basis, varargin{:});
  else
    assert(false);
  end
end
