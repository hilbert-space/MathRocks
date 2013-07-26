function output = construct(this, V, T, I, options)
  [ output, arguments, body ] = ...
    construct@LeakagePower.PolynomialRegression(this, V, T, log(I), options);

  string = sprintf('@(%s)exp(%s)', arguments, body);
  output.evaluate = str2func(string);
end
