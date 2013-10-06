function result = computeSecondRawMoment(this, i, j)
  result = integral(@(x) this.evaluate(x, i, j).^2, 0, 1);
end
