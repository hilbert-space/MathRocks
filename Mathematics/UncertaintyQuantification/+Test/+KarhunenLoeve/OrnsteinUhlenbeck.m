function OrnsteinUhlenbeck
  setup;

  sampleCount = 1e3;

  kernel = @(s, t) exp(-abs(s - t) / 1);
  domainBoundary = 1;

  kl = KarhunenLoeve( ...
    'kernel', kernel, ...
    'domainBoundary', domainBoundary, ...
    'reductionThreshold', 0.95);

  plot(kl);

  dimensionCount = kl.dimensionCount;

  x = linspace(-domainBoundary, domainBoundary, 50);
  z = randn(sampleCount, dimensionCount);
  k = zeros(dimensionCount, length(x));

  for i = 1:dimensionCount
    k(i, :) = kl.functions{i}(x);
  end

  u = z * diag(sqrt(kl.values)) * k;

  Plot.figure(1000, 600);
  [ X1, X2 ] = meshgrid(x);
  C = cov(u);
  mesh(X1, X2, C);
  hold on;

  C = kernel(X1, X2);
  plot3(X1, X2, C, 'k.', 'MarkerSize', 10);
end
