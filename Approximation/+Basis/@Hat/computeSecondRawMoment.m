function result = computeSecondRawMoment(this, i, j)
  result = integral(@(Y) (this.evaluate(Y.', i, j).^2).', 0, 1);
end
