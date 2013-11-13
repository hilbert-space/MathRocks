function surrogate = construct(this, options)
  parameterNames = this.parameterNames;
  parameterCount = this.parameterCount;

  %
  % The assumed expression for the leakage current,
  % which should be linear w.r.t. temperature, is
  %
  % I = a * T + b * exp(c + d * X + e * Y + ...) + z
  %   = alpha * T + beta.
  %

  %
  % Create symbols for the parameters and find the target
  %
  Tindex = NaN;
  Xs = sym(zeros(1, parameterCount));
  for i = 1:parameterCount
    Xs(i) = sym(parameterNames{i});
    if strcmp(parameterNames{i}, 'T')
      Tindex = i;
    end
  end
  assert(~isnan(Tindex));

  Ts = Xs(Tindex);

  %
  % Create symbols for the coefficients
  %
  Cs = sym('C%d', [ 1, parameterCount + 3 ]);

  %
  % Constract the alpha and beta coefficients
  %
  alpha = Cs(Tindex);

  beta = sym(0);
  for i = 1:parameterCount
    if i == Tindex, continue; end
    beta = beta + Cs(i) * Xs(i);
  end
  beta = Cs(parameterCount + 1) * ...
    exp(Cs(parameterCount + 2) + beta) + Cs(parameterCount + 3);

  Fs = alpha * Ts + beta;

  expression = struct;
  expression.formula = Fs;
  expression.parameters = Xs;
  expression.coefficients = Cs;

  surrogate = Fitting.Regression.Custom( ...
    options, 'expression', expression);
end
