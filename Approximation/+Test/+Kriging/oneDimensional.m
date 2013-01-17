function oneDimensional
  clear all;
  close all;

  setup;

  a = -10;
  b = +10;

  function y = evaluate(x)
    y = 4 * x.^2 + 20 * sin(2 * x) - 14 * x + 1;
  end

  surrogate = Kriging(@(u) evaluate(a + (b - a) * u), ...
    'nodeCount', 20);

  x = linspace(a, b, 50)';

  y1 = evaluate(x);
  [ y2, rmse ] = surrogate.evaluate((x - a) / (b - a));

  figure;
  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));
  line(x, y2 - rmse, 'Color', Color.pick(2), 'LineStyle', '--');
  line(x, y2 + rmse, 'Color', Color.pick(2), 'LineStyle', '--');
end
