function [ P, M ] = toMatrix(p, rvMarker, coeffMarker)
  %
  % Notation:
  %
  %   * dimension     - # of stochastic dimensions,
  %   * codimension   - # of deterministic dimensions,
  %   * terms         - # of polynomial terms,
  %   * monomialTerms - # of the corresponding monomial terms.
  %
  % Output:
  %
  %   * P - the matrix of the exponents of the RVs for each monomial,
  %   * M - the mapping matrix from the polynomial coefficients to
  %         the monomial coefficients.
  %

  assert(p.ConstantValue == 0, 'Not implemented yet.');

  if nargin < 2, rvMarker = 'x'; end
  if nargin < 3, coeffMarker = 'a'; end

  rvI = [];
  rvID = [];
  coeffI = [];
  coeffID = [];

  for i = 1:length(p.Variables)
    %
    % A name of a variable?
    %
    match = regexp(p.Variables{i}, [ rvMarker, '(\d+)' ], 'tokens');
    if ~isempty(match)
      rvI(end + 1) = i;
      rvID(end + 1) = str2num(match{1}{1});
      continue;
    end

    %
    % A name of a coefficient?
    %
    match = regexp(p.Variables{i}, [ coeffMarker, '(\d+)' ], 'tokens');
    if ~isempty(match)
      coeffI(end + 1) = i;
      coeffID(end + 1) = str2num(match{1}{1});
      continue;
    end

    assert(false, 'The format of the polynomial is invalid.');
  end

  %
  % Ensure that all the coefficients are not raised in any powers.
  %
  [ ~, ~, V ] = find(p.Exponents(:, coeffI));
  assert(all(V == 1), ...
    'The format of the coefficients is invalid.');

  terms = length(coeffI);
  dimension = length(rvI);

  %
  % Sort the variable and coefficient in the ascending order.
  %
  [ V, I ] = sort(rvID);
  assert(all((V - (1:dimension)) == 0), ...
    'The format of the variables is invalid.');
  rvI = rvI(I);

  [ V, I ] = sort(coeffID);
  assert(all((V - (1:terms)) == 0), ...
    'The format of the coefficients is invalid.');
  coeffI = coeffI(I);

  P = p.Exponents(:, rvI);

  monomialTerms = size(p.Exponents, 1);

  M = zeros(monomialTerms, terms);

  coeffExp = p.Exponents(:, coeffI);
  for i = 1:monomialTerms
    k = find(coeffExp(i, :));
    assert(length(k) == 1, ...
      'There should be only one coefficient per monomial.');
    M(i, k) = p.Coefficients(i);
  end

  %
  % Merge the monomials that have exponents all equal to zero.
  %
  I = [];
  for i = 1:monomialTerms
    if all(P(i, :) == 0), I(end + 1) = i; end
  end

  P(I(2:end), :) = [];
  M(I(1), :) = M(I(1), :) + sum(M(I(2:end), :), 1);
  M(I(2:end), :) = [];
end
