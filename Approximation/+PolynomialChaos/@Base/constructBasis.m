function Basis = constructBasis(this, x, order, index)
  dimension = length(x);

  %
  % Create the univariate basis.
  %
  basis(1, :) = this.constructUnivariateBasis(x(1), order);
  assert(numel(basis(1, :)) == order + 1, 'The number of terms is invalid.');

  %
  % If there is only one stochastic dimension,
  % we do not need to do anything else.
  %
  if dimension == 1
    Basis = basis(1, :);
    return;
  end

  %
  % Clone the first 1D polynomial.
  %
  for i = 2:dimension
    basis(i, :) = subs(basis(1, :), x(1), x(i));
  end

  terms = size(index, 1);

  for i = 1:terms
    Basis(i) = basis(1, index(i, 1));
    for j = 2:dimension
      Basis(i) = Basis(i) * basis(j, index(i, j));
    end
  end
end
