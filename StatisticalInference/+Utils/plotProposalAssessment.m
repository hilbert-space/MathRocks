function plotProposalAssessment(theta, assessment)
  parameterCount = length(assessment);

  cols = floor(sqrt(parameterCount));
  rows = ceil(parameterCount / cols);

  c1 = Color.pick(1);
  c2 = Color.pick(2);
  c3 = Color.pick(5);

  for i = 1:parameterCount
    subplot(rows, cols, i);

    grid = assessment(i).grid;
    logPosterior = assessment(i).logPosterior;
    logPosteriorApproximation = assessment(i).logPosteriorApproximation;

    line(grid, logPosterior, 'Color', c1);
    line(grid, logPosteriorApproximation, 'Color', c2);

    box off;

    yBound = ylim;
    yBound = [ floor(yBound(1)), ceil(yBound(2)) ];
    xBound = [ grid(1), grid(end) ];
    xBound = round(xBound * 1000) / 1000;

    line(theta(i) * [ 1 1 ], yBound, 'Color', c3);

    Plot.limit(xBound, yBound);
    set(gca, 'XTick', xBound);
    set(gca, 'YTick', yBound);

    drawnow;
  end

  Plot.legend('Log-posterior', 'Approximated log-posterior', 'Log-posterior mode');
end
