function assessGenz
  setup;

  dimensionCount = 2;
  expectation = (exp(1) - 1)^dimensionCount;
  variance = (0.5 * (exp(2) - 1))^dimensionCount - expectation^2;

  assess(@f6, ...
    'inputCount', dimensionCount, ...
    'exactExpectation', expectation, ...
    'exactVariance', variance, ...
    'sampleCount', 1e4);
end

function y = f6(x)
  y = exp(sum(x, 2));
end
