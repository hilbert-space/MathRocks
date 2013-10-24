function [ Yij, Li, Mi ] = computeNodes(~, I, J)
  [ indexCount, dimensionCount ] = size(I);

  K = I ~= 1;

  Mi = ones(indexCount, dimensionCount, 'uint32');
  Mi(K) = 2.^(uint32(I(K)) - 1) + 1;

  Li = ones(indexCount, dimensionCount);
  Li(K) = 1 ./ (double(Mi(K)) - 1);

  Yij = 0.5 * ones(indexCount, dimensionCount);
  Yij(K) = (double(J(K)) - 1) .* Li(K);
end
