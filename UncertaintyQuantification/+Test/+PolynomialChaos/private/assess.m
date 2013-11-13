function assess(target, varargin)
  options = Options( ...
    'basis', 'Hermite', ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'order', 4, ...
    'sampleCount', 1e4, ...
    varargin{:});

  distribution = options.get('distribution', []);

  surrogate = PolynomialChaos(options);

  surrogateOutput = surrogate.construct(target);
  surrogateData = surrogate.sample(surrogateOutput, options.sampleCount);

  display(surrogate);
  plot(surrogate, surrogateOutput, false);

  if isempty(distribution)
    mcData = target(surrogate.distribution.sample( ...
      options.sampleCount, options.inputCount));
  else
    mcData = distribution.sample(options.sampleCount, options.inputCount);
  end

  fprintf('Monte Carlo:\n');
  fprintf('  Expectation: %.4f\n', mean(mcData));
  fprintf('  Variance:    %.4f\n', var(mcData));

  surrogateStats = surrogate.analyze(surrogateOutput);

  fprintf('Polynomial chaos:\n');
  fprintf('  Expectation: %.4f\n', surrogateStats.expectation);
  fprintf('  Variance:    %.4f\n', surrogateStats.variance);

  Statistic.compare(mcData, surrogateData, 'draw', true);
  Plot.legend('Monte Carlo', 'Polynomial chaos');

  if isempty(distribution), return; end

  fprintf('Exact:\n');
  fprintf('  Expectation: %.4f\n', distribution.expectation);
  fprintf('  Variance:    %.4f\n', distribution.variance);

  x = xlim(gca);
  x = linspace(x(1), x(2), 200);
  h = line(x, distribution.pdf(x), 'Color', Color.pick(5), 'LineStyle', '--');

  set(h, 'erasemode', 'xor');
  set(h, 'erasemode', 'background');
  Plot.legend('Monte Carlo', 'Polynomial chaos', 'Exact');
end
