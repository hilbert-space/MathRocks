function OrnsteinUhlenbeck
  setup;

  sampleCount = 1e3;

  kernel = @(s, t) exp(-abs(s - t) / 1);
  domainBoundary = 1;
  dimensionCount = 6;

  kl = KarhunenLoeve( ...
    'kernel', kernel, ...
    'domainBoundary', domainBoundary, ...
    'dimensionCount', dimensionCount);

  [ X1, X2 ] = meshgrid(linspace(-domainBoundary, domainBoundary, 50));

  n = ceil(sqrt(dimensionCount));
  m = ceil(dimensionCount / n);

  Plot.figure(1000, 600);
  for i = 1:dimensionCount
    subplot(m, n, i);
    C = kl.values(i) * kl.functions{i}(X1) .* kl.functions{i}(X2);
    surfc(X1, X2, C);
  end

  Plot.figure(1000, 600);
  Plot.line(1:dimensionCount, kl.values);

  Plot.figure(1000, 600);
  r = linspace(-domainBoundary, domainBoundary);
  for i = 1:dimensionCount
    Plot.line(r, kl.functions{i}(r), 'number', i);
  end

  z = randn(sampleCount, dimensionCount);
  k = zeros(dimensionCount, length(r));

  for i = 1:dimensionCount
    k(i, :) = kl.functions{i}(r);
  end

  u = z * diag(sqrt(kl.values)) * k;

  Plot.figure(1000, 600);
  [ R1, R2 ] = meshgrid(r, r);
  C = cov(u);
  mesh(R1, R2, C);
  hold on;

  C = kernel(R1, R2);
  plot3(R1, R2, C, 'k.', 'MarkerSize', 10);
end
