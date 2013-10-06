function validate(basis, i, j)
  J = basis.constructOrderIndex(i);

  if any(J == j), return; end

  fprintf('Order %d is not valid for level %d. Available orders:\n', j, i);
  disp(J);

  error('Use one of the above orders.');
end
