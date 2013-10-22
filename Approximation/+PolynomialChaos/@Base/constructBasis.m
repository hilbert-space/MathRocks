function Basis = constructBasis(this, x, order, index)
  inputCount = length(x);

  %
  % Create the univariate basis.
  %
  basis(1, :) = this.constructUnivariateBasis(x(1), order);
  assert(numel(basis(1, :)) == order + 1, 'The number of terms is invalid.');

  %
  % If there is only one stochastic dimension,
  % we do not need to do anything else.
  %
  if inputCount == 1
    Basis = basis(1, :);
    return;
  end

  %
  % Clone the first 1D polynomial.
  %
  for i = 2:inputCount
    basis(i, :) = subs(basis(1, :), x(1), x(i));
  end

  termCount = size(index, 1);

  Basis = sympoly(zeros(1, termCount));
  for i = 1:termCount
    Basis(i) = basis(1, index(i, 1));
    for j = 2:inputCount
      Basis(i) = Basis(i) * basis(j, index(i, j));
    end
  end
end
