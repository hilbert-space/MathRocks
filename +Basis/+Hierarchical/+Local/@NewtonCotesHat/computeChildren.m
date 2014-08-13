function [Ichild, Jchild] = computeChildren(~, Iparent, Jparent)
  [parentCount, dimensionCount] = size(Iparent);
  childCount = 2 * parentCount * dimensionCount - nnz(Iparent == 2);

  Ichild = zeros(childCount, dimensionCount, 'uint8');
  Jchild = zeros(childCount, dimensionCount, 'uint32');

  count = 0;
  for i = 1:parentCount
    for j = 1:dimensionCount
      switch Iparent(i, j)
      case 1
        range = (count + 1):(count + 2);

        Ichild(range, :) = [Iparent(i, :); Iparent(i, :)];
        Jchild(range, :) = [Jparent(i, :); Jparent(i, :)];

        Ichild(range, j) = Ichild(range, j) + 1;
        Jchild(range, j) = [1; 3];

        count = count + 2;
      case 2
        count = count + 1;

        Ichild(count, :) = Iparent(i, :);
        Jchild(count, :) = Jparent(i, :);

        Ichild(count, j) = Ichild(count, j) + 1;
        Jchild(count, j) = Jchild(count, j) + 1; % 1 -> 2, 3 -> 4
      otherwise
        range = (count + 1):(count + 2);

        Ichild(range, :) = [Iparent(i, :); Iparent(i, :)];
        Jchild(range, :) = [Jparent(i, :); Jparent(i, :)];

        Ichild(range, j) = Ichild(range, j) + 1;
        Jchild(range, j) = [2 * Jparent(i, j) - 2; ...
          2 * Jparent(i, j)];

        count = count + 2;
      end
    end
  end

  %
  % The child nodes have been identify, but they may not be unique.
  % Therefore, we need to filter out all duplicates.
  %
  [~, I] = unique([Ichild, Jchild], 'rows');
  Ichild = Ichild(I, :);
  Jchild = Jchild(I, :);
end
