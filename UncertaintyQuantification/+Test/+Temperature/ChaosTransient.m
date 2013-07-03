function ChaosTransient(varargin)
  close all;
  setup;

  options = Options(varargin{:});

  iterationCount = options.get('iterationCount', 10);

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);
  options = Configure.polynomialChaos(options);

  plot(options.die);
  plot(options.schedule);
  plot(options.power, options.dynamicPower);

  chaos = Temperature.Chaos.Transient(options);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = chaos.compute(options.dynamicPower);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  time = options.samplingInterval * (1:options.stepCount);

  Utils.plotTemperatureVariation(time, { Utils.toCelsius(Texp) }, { output.Tvar });
  showCoefficients(time, { output.coefficients });
end

function showCoefficients(~, coefficientSet)
  setCount = length(coefficientSet);
  [ ~, processorCount, ~ ] = size(coefficientSet{1});

  for i = 1:processorCount
    figure;
    for j = 1:setCount
      subplot(1, setCount, j);
      heatmap(flipud(abs(squeeze(coefficientSet{j}(2:end, i, :)))));
      Plot.title('Magnitude (PE%d)', i);
      Plot.label('Time', 'Coefficient');
    end
  end
end
