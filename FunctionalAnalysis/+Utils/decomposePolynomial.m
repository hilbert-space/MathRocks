function [P, M] = decomposePolynomial(polynomial, x, a)
  %
  % Represents a multivariate polynomial as a set of two matrices
  % with respect to the monomials of the polynomial:
  %
  % P --- a (# of terms) x (# of variables) matrix of the exponents
  % of each of the variables in each of the monomials.
  %
  % M --- a (# of terms) x (# of terms) matrix mapping the polynomial
  % coefficients to the coefficients of the monomials.
  %
  [coefficients, terms] = coeffs(expand(polynomial), x);

  dimensionCount = length(x);
  termCount = length(terms);
  assert(termCount == length(a));

  P = zeros(termCount, dimensionCount);
  M = zeros(termCount, termCount);

  for i = 1:termCount
    match = regexp(char(terms(i)), 'x(\d+)(\^\d+)?', 'tokens');
    for j = 1:length(match)
      n = str2double(match{j}{1});
      if isempty(match{j}{2})
        p = 1;
      else
        p = str2double(match{j}{2}(2:end));
      end
      P(i, n) = p;
    end

    match = regexp(char(coefficients(i)), 'a(\d+)', 'tokens');
    I = cellfun(@(m) str2double(m{1}), match);
    M(i, I) = double(coeffs(coefficients(i), a(fliplr(I))));
  end
end
