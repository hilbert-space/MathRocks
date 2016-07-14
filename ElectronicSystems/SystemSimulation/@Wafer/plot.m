function plot(this, index)
  if nargin == 1, index = []; end

  F = this.floorplan;
  DF = this.die.floorplan;
  DS = max(this.die.width, this.die.height);

  W = DF(:, 1);
  H = DF(:, 2);
  X = DF(:, 3);
  Y = DF(:, 4);

  figure('Position', [100, 100, 600, 600]);

  for i = 1:size(F, 1)
    if ismember(i, index), continue; end

    h = draw(F(i, 3), F(i, 4), DS, DS);
    set(h, 'FaceColor', 0.90 * [1 1 1], ...
      'EdgeColor', 0 * [1 1 1], 'LineWidth', 1);

    for j = 1:size(DF, 1)
      h = draw(F(i, 1) + X(j), F(i, 2) + Y(j), W(j), H(j));
      set(h, 'FaceColor', Color.alpha(Color.pick(j), [1, 1, 1], 0.8), ...
        'EdgeColor', 'None');
    end
  end

  line(F(index, 3) + DS / 2, F(index, 4) + DS / 2, ...
    'Color', 'k', 'Marker', 'x', 'MarkerSize', 20, ...
    'LineStyle', 'None', 'LineWidth', 2);

  Plot.title('%d dies, %d cores each', size(F, 1), length(W));
  axis tight;
end

function h = draw(x, y, w, h)
  h = patch([x, x, x + w, x + w], [y, y + h, y + h, y], zeros(1, 4));
end
