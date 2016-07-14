function plot(this, output)
  processorCount = numel(output.eta);

  division = 100;
  function time = drawOne(eta, varargin)
    expectation = eta * gamma(1 + 1 / this.beta);
    time = 3 * (0:(division - 1)) * expectation / division;
    line(Utils.toYears(time), wblpdf(time, eta, this.beta), varargin{:});
    Plot.vline(Utils.toYears(eta), 'LineStyle', '--', varargin{:});
  end

  Plot.figure(800, 700);

  subplot(2, 1, 1);
  Plot.label('Time, years', 'Probability density');
  Plot.title('Marginal failure distributions');

  timeHorizon = 0;

  legend = {};
  for i = 1:processorCount
    timeHorizon = max(timeHorizon, ...
      max(drawOne(output.eta(i), 'Color', Color.pick(i))));
    legend{end + 1} = ['Density ', num2str(i)];
    legend{end + 1} = ['Expectation ', num2str(i)];
  end
  Plot.legend(legend{:});

  subplot(2, 1, 2);
  Plot.label('Time, years', 'Probability density');
  Plot.title('Joint failure distribution');

  timeHorizon = min(timeHorizon, ...
    3 * max(drawOne(output.Eta, 'Color', 'k')));
  Plot.legend('Density', 'Expectation');

  subplot(2, 1, 1);
  xlim([0, Utils.toYears(timeHorizon)]);
end
