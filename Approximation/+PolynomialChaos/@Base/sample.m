function [ Exp, Var, Data ] = sample(this, f, points)
  if nargin < 3, points = 1e4; end

  codimension = this.codimension;

  %
  % Obtain the coefficients.
  %
  coefficients = this.expand(f);

  %
  % Straight-forward stats.
  %
  Exp = coefficients(:, 1);
  Var = diag(sum(coefficients(:, 2:end).^2 .* ...
    Utils.replicate(this.norm(2:end), codimension, 1), 2));

  %
  % Now, sample.
  %
  Data = transpose(this.evaluate(coefficients, ...
    this.distribution.sample(this.dimension, points)));
end
