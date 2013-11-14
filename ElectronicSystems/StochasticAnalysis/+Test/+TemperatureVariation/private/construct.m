function [ surrogate, stats, output ] = construct(varargin)
  options = Options('sampleCount', 1e4, varargin{:});

  surrogate = TemperatureVariation(options);

  name = class(surrogate);
  sampleCount = options.sampleCount;

  time = tic;
  fprintf('%s: construction...\n', name);
  output = surrogate.compute(options.dynamicPower);
  fprintf('%s: done in %.2f seconds.\n', name, toc(time));

  display(surrogate, output);
  if surrogate.inputCount <= 3
    plot(surrogate, output);
  end

  time = tic;
  fprintf('%s: analysis...\n', name);
  stats = surrogate.analyze(output);
  fprintf('%s: done in %.2f seconds.\n', name, toc(time));

  computeExpectation = ~isfield(stats, 'expectation') || ...
    isempty(stats.expectation) || any(isnan(stats.expectation(:)));
  computeVariance = ~isfield(stats, 'variance') || ...
    isempty(stats.variance) || any(isnan(stats.variance(:)));

  if ~isfield(output, 'data') && ...
    (nargout > 2 || computeExpectation || computeVariance)
 
    time = tic;
    fprintf('%s: collecting %d samples...\n', name, sampleCount);
    output.data = surrogate.sample(output, sampleCount);
    fprintf('%s: done in %.2f seconds.\n', name, toc(time));
  end

  if computeExpectation
    stats.expectation = reshape(mean(output.data, 1), ...
      options.processorCount, []);
  end

  if computeVariance
    stats.variance = reshape(var(output.data, [], 1), ...
      options.processorCount, []);
  end
end
