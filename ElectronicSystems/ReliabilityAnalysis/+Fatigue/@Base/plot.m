function plot(this, output)
  processorCount = numel(output.eta);

  division = 100;

  function drawOne(eta, varargin)
    expectation = eta * gamma(1 + 1 / this.beta);
    time = 3 * (0:(division - 1)) * expectation / division;
    R = exp(-(time ./ eta).^this.beta);
    line(Utils.toYears(time), R, varargin{:});
    Plot.vline(Utils.toYears(eta), 'LineStyle', '--', varargin{:});
  end

  Plot.figure;
  Plot.label('Time, years', 'Probability');
  Plot.title('Survival time');

  title = {};

  for i = 1:processorCount
    drawOne(output.eta(i), 'Color', Color.pick(i));
    title{end + 1} = [ 'Processor ', num2str(i), ': Density' ];
    title{end + 1} = [ 'Processor ', num2str(i), ': Expectation' ];
  end

  drawOne(output.Eta, 'Color', 'k');
  title{end + 1} = 'Joint: Density';
  title{end + 1} = 'Joint: MTTF';

  Plot.legend(title{:});
end
