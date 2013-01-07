function plot(this)
  d = this.dimension;
  a = this.domainBoundary;

  figure;
  x = linspace(-a, a);
  for i = 1:d
    line(x, this.functions{i}(x), 'Color', Color.pick(i));
  end
  Plot.title('Eigenfunctions');

  figure;
  plot(1:d, this.values, 'Color', Color.pick(1));
  Plot.title('Eigenvalues');

  figure;
  plot(1:d, this.values ./ cumsum(this.values), 'Color', Color.pick(1));
  Plot.title('Eigenvalue contribution');
end
