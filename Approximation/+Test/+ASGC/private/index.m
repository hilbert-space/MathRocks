function I = index(i)
  switch i
  case 1
    I = 1;
  case 2
    I = [ 1 3 ];
  case 3
    I = [ 2 4 ];
  otherwise
    J = index(i - 1);
    I = [];
    for j = J
      I = [ I,  2 * j - 2, 2 * j ];
    end
  end
end