function assess(mcData, pc, pcData, pcOutput, distribution)
  display(pc);
  plot(pc, pcOutput);

  fprintf('Monte Carlo:\n');
  fprintf('  Expectation: %.4f\n', mean(mcData));
  fprintf('  Variance:    %.4f\n', var(mcData));

  fprintf('Polynomial chaos:\n');
  fprintf('  Expectation: %.4f\n', pcOutput.expectation);
  fprintf('  Variance:    %.4f\n', pcOutput.variance);

  Statistic.compare(mcData, pcData, 'draw', true);

  if nargin > 4
    fprintf('Exact:\n');
    fprintf('  Expectation: %.4f\n', distribution.expectation);
    fprintf('  Variance:    %.4f\n', distribution.variance);

    x = xlim(gca);
    x = linspace(x(1), x(2), 200);
    h = line(x, distribution.pdf(x), ...
      'Color', Color.pick(5), 'LineStyle', '--');

    set(h,'erasemode','xor');
    set(h,'erasemode','background');
    legend('Monte Carlo', 'Polynomial Chaos', 'Exact');
  else
    legend('Monte Carlo', 'Polynomial Chaos');
  end
end
