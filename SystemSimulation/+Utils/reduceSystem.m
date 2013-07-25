function [ A, B, C, D ] = reduceSystem(A, B, C, D, threshold, limit)
  s = ss(A, B, C, D);

  [ L, baldata ] = hsvd(s);

  dimensionCount = size(A, 1);
  dimensionCount = max(Utils.chooseSignificant(L, threshold), ...
    floor(dimensionCount * limit));

  r = balred(s, dimensionCount, 'Elimination', 'Truncate', ...
    'Balancing', baldata);

  A = r.a;
  B = r.b;
  C = r.c;
  D = r.d;
end
