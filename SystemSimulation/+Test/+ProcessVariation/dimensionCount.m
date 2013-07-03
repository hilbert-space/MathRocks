function dimensionCount
  setup;
  close all;

  sampleCount = 1e5;
  processorCount = [ 2 4 8 16 32 ];

  for i = 1:length(processorCount)
    options = configure('processorCount', processorCount(i));

    process = ProcessVariation.(options.processModel)(options.processOptions);

    title = sprintf('Processors: %d, Variables: %d\n', ...
      processorCount(i), process.dimensionCount);

    plot(options.die);
    Plot.title(title);

    fprintf(title);
    fprintf('%10s%20s%15s\n', 'Processor', 'Expectation, nm', 'Deviation, %');

    L = process.sample(sampleCount);
    expectation = mean(L, 1) * 1e9;
    deviation = sqrt(var(L, 0, 1)) * 1e9;

    for j = 1:processorCount(i)
      fprintf('%10d%20.2f%15.2f\n', j, expectation(j), ...
        deviation(j) / expectation(j) * 100);
    end

    fprintf('\n');
  end
end

function options = configure(varargin)
  options = Options(varargin{:});

  processorCount = options.getSet('processorCount', 4);

  options.die = Die('floorplan', ...
    File.join('+Test', 'Assets', sprintf('%03d.flp', processorCount)));

  Lnom = 45e-9;

  %
  % Process variation
  %
  function K = correlate(eta, lse, lou, s, t)
    %
    % Squared exponential kernel
    %
    Kse = exp(-sum((s - t).^2, 1) / lse^2);

    %
    % Ornstein-Uhlenbeck kernel
    %
    rs = sqrt(sum(s.^2, 1));
    rt = sqrt(sum(t.^2, 1));
    Kou = exp(-abs(rs - rt) / lou);

    K = eta * Kse + (1 - eta) * Kou;
  end

  eta = 0.50;
  lse = 0.50 * max(options.die.width, options.die.height);
  lou = lse;

  options.processModel = 'Beta';
  options.processOptions = Options( ...
    'die', options.die, ...
    'expectation', Lnom, ...
    'deviation', 0.05 * Lnom, ...
    'kernel', { @correlate, eta, lse, lou }, ...
    'globalPortion', 0.5, ...
    'threshold', 0.99);
end
