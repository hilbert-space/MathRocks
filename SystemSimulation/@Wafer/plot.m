function plot(this)
  L = this.layout;
  F = this.floorplan;

  DW = this.dieWidth;
  DH = this.dieHeight;

  W = F(:, 1);
  H = F(:, 2);
  X = F(:, 3);
  Y = F(:, 4);

  figure('Position', [ 250 250 500 500 ]);

  for i = 1:size(L, 1)
    x = L(i, 1);
    y = L(i, 2);

    h = draw(x, y, DW, DH);
    set(h, 'FaceColor', 0.70 * [ 1 1 1 ]);
    set(h, 'EdgeColor',        [ 1 1 1 ]);

    for j = 1:size(F, 1)
      h = draw(x + X(j), y + Y(j), W(j), H(j));
      set(h, 'FaceColor', Color.pick(j));
      set(h, 'EdgeColor', [ 1 1 1 ]);
    end
  end

  Plot.title('%d dies, %d cores each', prod(size(L)), length(W));
end

function h = draw(x, y, W, H)
  h = patch([ x, x, x + W, x + W ], [ y, y + H, y + H, y ], zeros(1, 4));
end
