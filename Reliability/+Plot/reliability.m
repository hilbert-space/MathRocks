function reliability(T, output)
  [ processorCount, stepCount ] = size(T);

  division = 100;
  period = stepCount * output.samplingInterval;
  Z = gamma(1 + 1 / output.beta);

  function drawOne(damage, MTTF, varargin)
    eta = period / (Z * damage);
    time = 3 * (0:(division - 1)) * MTTF / division;
    R = exp(-(time ./ eta).^output.beta);
    line(Utils.toYears(time), R, varargin{:});
    Plot.vline(Utils.toYears(eta), 'LineStyle', '--', varargin{:});
  end

  Plot.figure;
  Plot.label('Time, years', 'Probability');
  Plot.title('Survival time');

  title = {};

  for i = 1:processorCount
    drawOne(output.damage(i), output.MTTF(i), 'Color', Color.pick(i));
    title{end + 1} = [ 'Processor ', num2str(i), ': Density' ];
    title{end + 1} = [ 'Processor ', num2str(i), ': MTTF' ];
  end

  drawOne(output.totalDamage, output.totalMTTF, 'Color', 'k');
  title{end + 1} = 'Joint: Density';
  title{end + 1} = 'Joint: MTTF';

  Plot.legend(title{:});
end
