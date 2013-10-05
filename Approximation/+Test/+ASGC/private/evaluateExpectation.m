function result = evaluateExpectation(i, ~)
  switch i
  case 1
    result = 1;
  case 2
    result = 1 / 4;
  otherwise
    result = 2^(1 - i);
  end
end