function result = computeSecondRawMoment(i, j)
  result = integral(@(x) base(x, i, j).^2, 0, 1);
end
