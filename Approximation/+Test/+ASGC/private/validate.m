function validate(i, j)
  J = index(i);

  if any(J == j), return; end

  fprintf('Order %d is not valid for level %d. Use one of the following:\n', j, i);
  disp(J);
end
