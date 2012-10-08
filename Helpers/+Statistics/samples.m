function number = samples
  confidence = 0.99;
  accuracy = 0.005;
  quantile = abs(Stats.quantile((1 - confidence) / 2));
  probability = 0.05;
  number = quantile^2 * probability * (1 - probability) / accuracy^2;
end
