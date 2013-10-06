function assessStep
  setup;
  assess(@problem);
end

function y = problem(x)
  y = ones(size(x));
  y(x > 1/2) = 0;
end
