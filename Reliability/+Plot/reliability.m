function reliability(T, output)
  [ processorCount, stepCount ] = size(T);

  period = stepCount * output.samplingInterval;

  Z = gamma(1 + 1 / output.beta);

  Plot.figure;
  Plot.label('Time, s', 'Probability');
  Plot.title('Time without failures');

  division = 100;
  title = {};

  for i = 1:processorCount
    color = Color.pick(i);

    eta = period / (Z * output.damage(i));
    time = (0:(division - 1)) * output.MTTF(i) / division;
    R = exp(-(time ./ eta).^output.beta);

    line(time, R, 'Color', color);
    title{end + 1} = [ 'Processor ', num2str(i) ];
  end

  eta = period / (Z * output.totalDamage);
  time = (0:(division - 1)) * output.totalMTTF / division;
  R = exp(-(time ./ eta).^output.beta);

  line(time, R, 'Color', 'k', 'Line', '--');
  title{end + 1} = 'Total';

  legend(title{:});
end
