function result = call(basis, method, varargin)
  if isa(basis, 'HierarchicalBasis.NewtonCotesHat.Local')
    result = Utils.instantiate( ...
      [ 'Test.HierarchicalBasis.NewtonCotesHat.', method ], ...
      basis, varargin{:});
  else
    assert(false);
  end
end
