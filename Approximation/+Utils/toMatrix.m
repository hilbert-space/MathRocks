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
  % Merge the monomials that have the same exponents.
  %
  [ P, I, J ] = unique(P, 'rows');
  uniqueMonomialTerms = size(P, 1);

  %
  % NOTE: We use the following:
  %
  %   newP = oldP(I),
  %   oldP = newP(J).
  %

  for i = 1:uniqueMonomialTerms
    K = find(J == i);
    count = length(K);
    if count == 1
      %
      % This monomial is unique.
      %
      continue;
    elseif count > 1
      %
      % This monomial is not unique. Find the one
      % that is preserved by the index I.
      %
      k = find(ismember(K, I));
      assert(length(k) == 1);
      switch k
      case 1
        %
        % Sum the tail.
        %
        M(K(k), :) = M(K(k), :) + ...
          sum(M(K(2:end), :), 1);
      case count
        %
        % Sum the head.
        %
        M(K(k), :) = M(K(k), :) + ...
          sum(M(K(1:(end - 1)), :), 1);
      otherwise
        %
        % Sum around.
        %
        M(K(k), :) = M(K(k), :) + ...
          sum(M(K(1:(k - 1)), :), 1) + sum(M(K((k + 1):end), :), 1);
      end
    else
      assert(false);
    end
  end

  M = sparse(M(I, :));
end
