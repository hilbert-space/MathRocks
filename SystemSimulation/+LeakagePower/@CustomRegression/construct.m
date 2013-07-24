function output = construct(this, Lgrid, Tgrid, Igrid, options)
  expression = options.expression;

  Fs = expression.F;
  Ls = expression.L;
  Ts = expression.T;
  Cs = expression.C;

  LT = [ Lgrid(:), Tgrid(:) ];
  I = Igrid(:);

  E = mean(LT, 1);
  D = std(LT, [], 1);

  LT = bsxfun(@rdivide, bsxfun(@minus, LT, E), D);

  coefficientCount = length(Cs);

  Gs = gradient(Fs, Cs);
  Hs = hessian(Fs, Cs);

  Ff = Utils.toFunction(Fs, [ Ls, Ts ], 'columns', Cs);
  Gf = cell(coefficientCount, 1);
  Hf = cell(coefficientCount, coefficientCount);
  for i = 1:coefficientCount
    Gf{i} = Utils.toFunction(Gs(i), [ Ls, Ts ], 'columns', Cs);
    for j = i:coefficientCount
      Hf{i, j} = Utils.toFunction(Hs(i, j), [ Ls, Ts ], 'columns', Cs);
      Hf{j, i} = Hf{i, j};
    end
  end

  dataCount = length(I);

  function [ f, g, h ] = target(C)
    r = Ff(LT, C) - I;

    J = zeros(dataCount, coefficientCount);
    Q = zeros(coefficientCount, coefficientCount);

    for i = 1:coefficientCount
      J(:, i) = Gf{i}(LT, C);
      for j = i:coefficientCount
        hij = Hf{i, j}(LT, C);
        if isscalar(hij), hij = hij * ones(dataCount, 1); end
        Q(i, j) = hij' * r;
        Q(j, i) = Q(i, j);
      end
    end

    f = sum(r.^2) / 2;
    g = J' * r;
    h = J' * J + Q;
  end

  options = optimoptions('fminunc');
  options.GradObj = 'on';
  options.Hessian = 'on';
  options.Display = 'off';

  C = fminunc(@target, zeros(1, coefficientCount), options);

  Fs = subs(Fs, Cs, C);
  Fs = subs(Fs, Ls, (Ls - E(1)) / D(1));
  Fs = subs(Fs, Ts, (Ts - E(2)) / D(2));

  output.evaluate = Utils.toFunction(Fs, Ls, Ts);
end
