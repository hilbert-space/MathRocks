function [ alpha, beta ] = linearize(this, varargin)
  options = Options(varargin{:});

  parameterNames = this.parameterNames;
  parameterCount = this.parameterCount;
  pointCount = options.get('pointCount', 50);

  %
  % Obtain some data for fitting.
  %
  sweeps = cell(1, parameterCount);
  for i = 1:parameterCount
    mn = min(options.(parameterNames{i}));
    mx = max(options.(parameterNames{i}));
    sweeps{i} = linspace(mn, mx, pointCount);
  end

  X = cell(1, parameterCount);
  [ X{:} ] = ndgrid(sweeps{:});
  for i = 1:parameterCount
    X{i} = X{i}(:);
  end

  Y = this.fit.compute(X{:});
  X = cell2mat(X);

  %
  % The assumed expression for the leakage current
  % that should be linear w.r.t. the target (T) is
  %
  % I = a * T + b * exp(c + d * X + e * Y + ...)
  %   = alpha * T + beta.
  %
  % Create symbols for all the parameters and
  % find the target along the way.
  %
  Tindex = NaN;
  Xs = sym(zeros(1, parameterCount));
  for i = 1:parameterCount
    Xs(i) = sym(parameterNames{i});
    if strcmp(parameterNames{i}, options.target)
      Tindex = i;
    end
  end
  assert(~isnan(Tindex));

  Ts = Xs(Tindex);

  %
  % Create symbols for the coefficients.
  %
  Cs = sym(zeros(1, 2 + parameterCount));
  for i = 1:length(Cs)
    Cs(i) = sym(sprintf('C%d', i));
  end

  %
  % Constract the alpha and beta components.
  %
  beta = sym(0);
  for i = 1:parameterCount
    if i == Tindex, continue; end
    beta = beta + Cs(i) * Xs(i);
  end
  beta = Cs(i + 1) * exp(Cs(i + 2) + beta);
  alpha = Cs(Tindex);

  Fs = alpha * Ts + beta;

  [ ~, alpha, beta ] = Utils.constructCustomFit( ...
    Y, X, Fs, Xs, Cs, alpha * Ts, beta);

  delta = subs(alpha, Ts, 0);
  beta = beta + delta;
  alpha = subs(alpha - delta, Ts, 1);

  Xs = num2cell(Xs);

  this.linearization = Utils.toFunction( ...
    options.compose(alpha, beta), Xs{:});

  alpha = double(alpha);

  if nargout < 2, return; end

  beta = Utils.toFunction(beta, Xs{:});
end
