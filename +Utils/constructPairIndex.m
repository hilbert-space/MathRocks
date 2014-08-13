function I = constructPairIndex(count)
  I = zeros(count * (count + 1) / 2, 2);
  k = 0;
  for i = 1:count
    c = count - i + 1;
    I(k + (1:c), :) = [repmat(i, c, 1), (i:count)'];
    k = k + c;
  end
end
