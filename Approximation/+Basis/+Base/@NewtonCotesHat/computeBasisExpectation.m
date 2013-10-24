function result = computeBasisExpectation(~, I)
  [ I, ~, K ] = unique(I, 'rows');
  result = 2.^(1 - double(I));
  result(I == 1) = 1;
  result(I == 2) = 1 / 4;
  result = prod(result, 2);
  result = result(K);
end
