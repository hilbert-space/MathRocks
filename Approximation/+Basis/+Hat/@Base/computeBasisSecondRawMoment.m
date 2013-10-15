function result = computeBasisSecondRawMoment(~, I)
  [ I, ~, K ] = unique(I, 'rows');
  result = 2.^(2 - double(I)) / 3;
  result(I == 1) = 1;
  result(I == 2) = 1 / 6;
  result = prod(result, 2);
  result = result(K);
end
