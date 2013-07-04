function analyze(method, analysis, varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);

  switch method
  case 'Chaos'
    options = Configure.polynomialChaos(options);
  case 'ASGC'
    options = Configure.ASGC(options);
  end

  plot(options.die);
  plot(options.schedule);
  plot(options.power, options.dynamicPower);

  surrogate = Temperature.(method).(analysis)(options);

  iterationCount = options.get('iterationCount', 10);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = surrogate.compute(options.dynamicPower);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  time = options.samplingInterval * (1:options.stepCount);

  Utils.plotTemperatureVariation(time, ...
    { Utils.toCelsius(Texp) }, { output.Tvar });

  switch method
  case 'Chaos'
    showCoefficients(time, { output.coefficients });
  end
end

function showCoefficients(~, coefficientSet)
  setCount = length(coefficientSet);
  [ ~, processorCount, ~ ] = size(coefficientSet{1});

  for i = 1:processorCount
    figure;
    for j = 1:setCount
      subplot(1, setCount, j);
      heatmap(flipud(abs(squeeze(coefficientSet{j}(2:end, i, :)))));
      Plot.title('Magnitude %d', i);
      Plot.label('Time', 'Coefficient');
    end
  end
end
