function [ Yij, Li, Mi ] = computeBasisNodes(~, i)
  switch i
  case 1
    Yij = 0.5;
    Mi = uint32(1);
    Li = 1;
  case 2
    Yij = [ 0; 1 ];
    Mi = uint32(3);
    Li = 0.5;
  otherwise
    assert(i <= 32);
    Yij = transpose((2 * (1:2^(double(i) - 2)) - 1) * ...
      2^(-double(i) + 1));
    Mi = uint32(2^(i - 1) + 1);
    Li = 1 ./ (double(Mi) - 1);
  end
end
