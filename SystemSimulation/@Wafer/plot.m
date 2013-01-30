function plot(this, index)
  if nargin == 1, index = []; end

  F = this.floorplan;
  DF = this.dieFloorplan;
  DW = this.dieWidth;
  DH = this.dieHeight;
  DS = max(DW, DH);

  W = DF(:, 1);
  H = DF(:, 2);
  X = DF(:, 3);
  Y = DF(:, 4);

  figure('Position', [ 250, 250, 500, 500 ]);

  for i = 1:size(F, 1)
    h = draw(F(i, 3), F(i, 4), DS, DS);
    set(h, 'FaceColor', 0.90 * [ 1 1 1 ]);
    set(h, 'EdgeColor', 0.15 * [ 1 1 1 ]);
    for j = 1:size(DF, 1)
      h = draw(F(i, 1) + X(j), F(i, 2) + Y(j), W(j), H(j));
      if ismember(i, index)
        set(h, 'FaceColor', 0.25 * [ 1 1 1 ]);
      else
        set(h, 'FaceColor', Color.pick(j));
      end
      set(h, 'EdgeColor', 0.00 * [ 0 0 0 ]);
    end
  end

  Plot.title('%d dies, %d cores each', prod(size(F)), length(W));
  axis tight;
end

function h = draw(x, y, W, H)
  h = patch([ x, x, x + W, x + W ], [ y, y + H, y + H, y ], zeros(1, 4));
end
