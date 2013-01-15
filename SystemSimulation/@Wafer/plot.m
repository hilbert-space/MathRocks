function plot(this, index)
  if nargin == 1, index = []; end

  F = this.floorplan;
  DF = this.dieFloorplan;
  DW = this.dieWidth;
  DH = this.dieHeight;

  W = DF(:, 1);
  H = DF(:, 2);
  X = DF(:, 3);
  Y = DF(:, 4);

  figure('Position', [ 250 250 500 500 ]);

  for i = 1:size(F, 1)
    x = F(i, 1);
    y = F(i, 2);

    h = draw(x, y, DW, DH);

    if ismember(i, index)
      set(h, 'FaceColor', 0.17 * [ 1 1 1 ]);
      set(h, 'EdgeColor',        [ 1 1 1 ]);
    else
      set(h, 'FaceColor', 0.70 * [ 1 1 1 ]);
      set(h, 'EdgeColor',        [ 1 1 1 ]);

      for j = 1:size(DF, 1)
        h = draw(x + X(j), y + Y(j), W(j), H(j));
        set(h, 'FaceColor', Color.pick(j));
        set(h, 'EdgeColor', [ 1 1 1 ]);
      end
    end
  end

  Plot.title('%d dies, %d cores each', prod(size(F)), length(W));
end

function h = draw(x, y, W, H)
  h = patch([ x, x, x + W, x + W ], [ y, y + H, y + H, y ], zeros(1, 4));
end
