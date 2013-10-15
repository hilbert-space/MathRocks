function [ Yij, Li, Mi ] = computeNodes(~, I, J)
  Mi = 2.^(uint32(I) - 1) + 1;
  Mi(I == 1) = 1;

  Li = 1 ./ (double(Mi) - 1);
  Li(I == 1) = 1;

  Yij = (double(J) - 1) .* Li;
  Yij(I == 1) = 0.5;
end
