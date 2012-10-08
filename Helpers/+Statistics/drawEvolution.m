function h = drawEvolution(time, exp, var)
  h = figure;

  std = sqrt(var);
  count = size(exp, 1);

  for i = 1:count
    color = Utils.pickColor(i);
    line(time, exp(i, :), 'Color', color, 'LineWidth', 1.5);
    line(time, exp(i, :) + 3 * std(i, :), 'Color', color, 'LineStyle', '--');
  end
end
