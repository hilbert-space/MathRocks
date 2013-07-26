function [ compute, C ] = constructCustomFit(X, Y, Fs, Xs, Cs)
  E = mean(X, 1);
  S = std(X, [], 1);

  X = bsxfun(@rdivide, bsxfun(@minus, X, E), S);

  variableCount = length(Xs);
  coefficientCount = length(Cs);

  Ff = Utils.toFunction(Fs, Xs, 'columns', Cs);
  Js = jacobian(Fs, Cs);
  Jf = cell(1, coefficientCount);
  for i = 1:coefficientCount
    Jf{i} = Utils.toFunction(Js(i), Xs, 'columns', Cs);
  end

  dataCount = length(Y);

  function [ f, J ] = target(C)
    f = Ff(X, C) - Y;
    J = zeros(dataCount, coefficientCount);
    for i = 1:coefficientCount
      J(:, i) = Jf{i}(X, C);
    end
  end

  options = optimoptions('lsqnonlin');
  options.Algorithm = 'levenberg-marquardt';
  options.TolFun = 1e-8;
  options.Jacobian = 'on';
  options.Display = 'off';

  C = lsqnonlin(@target, zeros(1, coefficientCount), [], [], options);

  Fs = subs(Fs, Cs, C);
  for i = 1:variableCount
    Fs = subs(Fs, Xs(i), (Xs(i) - E(i)) / S(i));
  end

  Xs = num2cell(Xs);
  compute = Utils.toFunction(Fs, Xs{:});
end
