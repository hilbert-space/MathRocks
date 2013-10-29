function result = integrate(~, I, surpluses)
  result = 2.^(1 - double(I));
  result(I == 1) = 1;
  result(I == 2) = 1 / 4;
  result = prod(result, 2);

  if nargin < 3, return; end

  result = sum(bsxfun(@times, surpluses, result));
end
