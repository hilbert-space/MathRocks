function plotFloorplan(filename)
  DF = dlmread(filename, '', 0, 1);

  W = DF(:, 1);
  H = DF(:, 2);
  X = DF(:, 3);
  Y = DF(:, 4);

  DW = max(X + W);
  DH = max(Y + H);
  DS = max(DW, DH);

  figure('Position', [ 100, 100, DW / DS * 600, DH / DS * 600 ]);

  h = draw(0, 0, DW, DH);
  set(h, 'FaceColor', 0.90 * [ 1 1 1 ], ...
    'EdgeColor', 0 * [ 1 1 1 ], 'LineWidth', 1);

  for i = 1:size(DF, 1)
    h = draw(X(i), Y(i), W(i), H(i));
    set(h, 'FaceColor', Color.alpha(Color.pick(i), [ 1, 1, 1 ], 0.8), ...
      'EdgeColor', 'None');
  end

  Plot.title('%d-core die', size(DF, 1));
  axis tight;
end

function h = draw(x, y, w, h)
  h = patch([ x, x, x + w, x + w ], [ y, y + h, y + h, y ], zeros(1, 4));
end
