function [ A, B, C, D ] = reduceModelOrder(A, B, C, D, varargin)
  options = Options(varargin{:});

  threshold = options.threshold;
  limit = options.get('limit', 0);

  if threshold >= 1 || limit >= 1, return; end

  offset = options.get('offset', 1e-8);
  method = options.get('method', 'Truncate');

  s = ss(A, B, C, D);

  options = hsvdOptions('Offset', offset);
  [ L, baldata ] = hsvd(s, options);

  dimensionCount = size(A, 1);
  dimensionCount = max(Utils.countSignificant(L, threshold), ...
    floor(dimensionCount * limit));

  options = balredOptions('Offset', offset, 'StateElimMethod', method);
  r = balred(s, dimensionCount, options, baldata);

  A = r.a;
  B = r.b;
  C = r.c;
  D = r.d;
end
