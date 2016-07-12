function plot(this)
  window = [1000, 600];

  Plot.figure(window);
  x = linspace(-this.domainBoundary, this.domainBoundary, 50);
  for i = 1:this.dimensionCount
    Plot.line(x, this.functions{i}(x), 'number', i);
  end
  Plot.title('Eigenfunctions');

  Plot.figure(window);
  Plot.line(1:this.dimensionCount, this.values);
  Plot.title('Eigenvalues');

  Plot.figure(window);
  Plot.line(1:this.dimensionCount, this.values ./ cumsum(this.values));
  Plot.title('Contribution of the eigenvalues');

  Plot.figure(window);
  [X1, X2] = meshgrid(x);
  cols = ceil(sqrt(this.dimensionCount));
  rows = ceil(this.dimensionCount / cols);
  for i = 1:this.dimensionCount
    subplot(rows, cols, i);
    C = this.values(i) * this.functions{i}(X1) .* this.functions{i}(X2);
    surfc(X1, X2, C);
  end
end
