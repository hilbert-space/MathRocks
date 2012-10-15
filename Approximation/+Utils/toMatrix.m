function [ P, MT ] = toMatrix(p, rvMarker, coeffMarker)
  %
  % Notation:
  %
  %   * sdim   - the number of r.v.'s,
  %   * ddim   - the number of deterministic dimensions (cores),
  %   * terms  - the number of terms in the PC expansion,
  %   * mterms - the number of terms in the corresponding expanded
  %              polynomial into a sum of monomials.
  %
  % Output:
  %
  %   * P  - the matrix of the exponents of the r.v.'s for each monomial.
  %
  %     Exponents of r.v.'s
  %     (sdim x mterms)
  %
  %   * MT - the transpose mapping matrix from the PC expansion coefficients to
  %          the coefficients of the expanded polynomial.
  %
  %     Monomial coefficients   = Mapping matrix            * Polynomial coefficients
  %     (mterms x ddim)         = (mterms x terms)          * (terms x ddim)
  %
  %     Monomial coefficients^T = Polynomial coefficients^T * Mapping matrix^T
  %     (ddim x mterms)         = (ddim x terms)            * (terms x mterms)
  %

  assert(p.ConstantValue == 0, 'Not implemented yet.');

  if nargin < 2, rvMarker = 'x'; end
  if nargin < 3, coeffMarker = 'a'; end

  rvI = [];
  rvID = [];
  coeffI = [];
  coeffID = [];

  vars = length(p.Variables);

  for i = 1:vars
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

    error('The format of the polynomial is invalid.');
  end

  %
  % Ensure that all the coefficients are not raised in any powers.
  %
  [ ~, ~, V ] = find(p.Exponents(:, coeffI));
  assert(all(V == 1), 'The format of the coefficients is invalid.');

  terms = length(coeffI);
  sdim = length(rvI);

  %
  % Sort the variable and coefficient in the ascending order.
  %
  [ V, I ] = sort(rvID);
  assert(all((V - (1:sdim)) == 0), 'The format of the variables is invalid.');
  rvI = rvI(I);

  [ V, I ] = sort(coeffID);
  assert(all((V - (1:terms)) == 0), 'The format of the coefficients is invalid.');
  coeffI = coeffI(I);

  P = transpose(p.Exponents(:, rvI));

  mterms = size(p.Exponents, 1);

  MT = zeros(terms, mterms);

  coeffExp = p.Exponents(:, coeffI);
  for i = 1:mterms
    k = find(coeffExp(i, :));
    assert(length(k) == 1, 'There should be only one coefficient per monomial.');
    MT(k, i) = p.Coefficients(i);
  end

  %
  % Merge monomials where the exponents of r.v.'s are all zero.
  %
  I = [];
  for i = 1:mterms
    if all(P(:, i) == 0), I(end + 1) = i; end
  end

  P(:, I(2:end)) = [];
  MT(:, I(1)) = MT(:, I(1)) + sum(MT(:, I(2:end)), 2);
  MT(:, I(2:end)) = [];
end
