function result = integrate(~, indexes, surpluses, offsets, counts)
  result = 2.^(1 - double(indexes));
  result(indexes == 1) = 1;
  result(indexes == 2) = 1 / 4;
  result = prod(result, 2);

  if nargin < 5, return; end

  basis = result;
  result = 0;
  for i = 1:size(indexes, 1)
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    result = result + sum(surpluses(range, :) * basis(i), 1);
  end
end
