function inspectProposalAssessment(theta, assessment)
  parameterCount = length(assessment);

  cols = floor(sqrt(parameterCount));
  rows = ceil(parameterCount / cols);

  c1 = Color.pick(1);
  c2 = Color.pick(2);

  for i = 1:parameterCount
    subplot(rows, cols, i);

    grid = assessment(i).grid;
    logPosterior = assessment(i).logPosterior;
    logGaussianDensity = assessment(i).logGaussianDensity;

    line(grid, logPosterior, 'Color', c1);
    line(grid, logGaussianDensity, 'Color', c2);

    box off;

    yBound = ylim;
    yBound = [ floor(yBound(1)), ceil(yBound(2)) ];
    xBound = [ grid(1), grid(end) ];
    xBound = round(xBound * 100) / 100;

    line(theta(i) * [ 1 1 ], yBound, 'Color', 'k');

    if i == 1, Plot.legend('Perturbed', 'Gaussian'); end
    Plot.limit(xBound, yBound);
    set(gca, 'XTick', xBound);
    set(gca, 'YTick', yBound);

    drawnow;
  end

  Plot.name('Curvature at the posterior mode');
end
