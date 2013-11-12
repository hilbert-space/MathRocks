function varargout = constructCustomFit(Y, X, Fs, Xs, Cs, varargin)
  Ex = mean(X, 1);
  Sx = std(X, [], 1);
  X = bsxfun(@rdivide, bsxfun(@minus, X, Ex), Sx);

  Ey = mean(Y);
  Sy = std(Y);
  Y = (Y - Ey) / Sy;

  Fs = (Fs - Ey) / Sy;

  parameterCount = length(Xs);
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
    if nargout < 2, return; end
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

  varargin = [ { Fs }, varargin ];
  varargout = cell(1, length(varargin));

  Xs = num2cell(Xs);
  for i = 1:length(varargin)
    Fs = Sy * varargin{i} + Ey;
    Fs = subs(Fs, Cs, C);
    for j = 1:parameterCount
      Fs = subs(Fs, Xs{j}, (Xs{j} - Ex(j)) / Sx(j));
    end
    varargout{i} = Fs;
  end

  varargout{1} = Utils.toFunction(varargout{1}, Xs{:});
end
