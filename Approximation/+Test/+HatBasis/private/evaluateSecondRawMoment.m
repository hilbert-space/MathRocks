function result = evaluateSecondRawMoment(i, ~)
  switch i
  case 1
    result = 1;
  case 2
    result = 1 / 6;
  otherwise
    result = 2^(2 - i) / 3;
  end
end
