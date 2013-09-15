function output = construct(this, Z, XY, options)
  [ output, arguments, body ] = ...
    construct@Regression.Polynomial(this, log(Z), XY, options);

  string = sprintf('@(%s)exp(%s)', arguments, body);
  output.evaluate = str2func(string);
end
