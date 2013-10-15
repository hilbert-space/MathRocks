function [ Ichild, Jchild ] = computeChildren(~, Iparent, Jparent)
  [ parentCount, dimensionCount ] = size(Iparent);
  childCount = 2 * parentCount * dimensionCount - nnz(Iparent == 2);

  Ichild = zeros(childCount, dimensionCount);
  Jchild = zeros(childCount, dimensionCount);

  l = 0;
  for i = 1:parentCount
    for j = 1:dimensionCount
      switch Iparent(i, j)
      case 1
        r = (l + 1):(l + 2);

        Ichild(r, :) = [ Iparent(i, :); Iparent(i, :) ];
        Jchild(r, :) = [ Jparent(i, :); Jparent(i, :) ];

        Ichild(r, j) = Ichild(r, j) + 1;
        Jchild(r, j) = [ 1; 3 ];

        l = l + 2;
      case 2
        l = l + 1;

        Ichild(l, :) = Iparent(i, :);
        Jchild(l, :) = Jparent(i, :);

        Ichild(l, j) = Ichild(l, j) + 1;
        Jchild(l, j) = Jchild(l, j) + 1; % 1 -> 2, 3 -> 4
      otherwise
        r = (l + 1):(l + 2);

        Ichild(r, :) = [ Iparent(i, :); Iparent(i, :) ];
        Jchild(r, :) = [ Jparent(i, :); Jparent(i, :) ];

        Ichild(r, j) = Ichild(r, j) + 1;
        Jchild(r, j) = [ 2 * Jparent(i, j) - 2; ...
          2 * Jparent(i, j) ];

        l = l + 2;
      end
    end
  end

  %
  % The child nodes have been identify, but they may not be unique.
  % Therefore, we need to filter out all duplicates.
  %
  [ ~, I ] = unique([ Ichild, Jchild ], 'rows');
  Ichild = Ichild(I, :);
  Jchild = Jchild(I, :);
end
