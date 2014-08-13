function orders = computeLevelOrders(~, i)
  switch i
  case 1
    orders = uint32(1);
  case 2
    orders = uint32([1 3]);
  otherwise
    orders = 2 * (1:2^(uint32(i) - 2));
  end
end
