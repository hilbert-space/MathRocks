function result = computeSecondRawMoment(~, I)
  result = 2.^(2 - double(I)) / 3;
  result(I == 1) = 1;
  result(I == 2) = 1 / 6;
  result = prod(result, 2);
end
