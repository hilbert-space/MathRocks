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

  Ff = Utils.toFunction(Fs, [ Ls, Ts ], 'columns', Cs);
  Js = jacobian(Fs, Cs);
  Jf = cell(1, coefficientCount);
  for i = 1:coefficientCount
    Jf{i} = Utils.toFunction(Js(i), [ Ls, Ts ], 'columns', Cs);
  end

  dataCount = length(I);

  function [ f, J ] = target(C)
    f = Ff(LT, C) - I;
    J = zeros(dataCount, coefficientCount);
    for i = 1:coefficientCount
      J(:, i) = Jf{i}(LT, C);
    end
  end

  options = optimoptions('lsqnonlin');
  options.Algorithm = 'levenberg-marquardt';
  options.TolFun    = 1e-8;
  options.Jacobian  = 'on';
  options.Display   = 'off';

  C = lsqnonlin(@target, zeros(1, coefficientCount), [], [], options);

  Fs = subs(Fs, Cs, C);
  Fs = subs(Fs, Ls, (Ls - E(1)) / D(1));
  Fs = subs(Fs, Ts, (Ts - E(2)) / D(2));

  output.evaluate = Utils.toFunction(Fs, Ls, Ts);
end
