function output = construct(this, Lgrid, Tgrid, Igrid, options)
  [ output, arguments, body ] = construct@LeakagePower.PolynomialRegression( ...
    this, Lgrid, Tgrid, log(Igrid), options);

  string = sprintf('@(%s)exp(%s)', arguments, body);
  output.evaluate = str2func(string);
end
