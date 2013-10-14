function assessStep
  setup;
  assess(@problem, ...
    'maximalLevel', 40, ...
    'exactExpectation', 0.5, ...
    'exactVariance', 0.25);
end

function y = problem(x)
  y = ones(size(x));
  y(x > 1/2) = 0;
end
