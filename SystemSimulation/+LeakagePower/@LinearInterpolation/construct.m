function output = construct(this, Ldata, Tdata, Idata, options)
  fitobject = performInterpolation(Ldata, Tdata, Idata);

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = feval(fitobject, this.Lnom, this.Tref);
    powerScale = Pmean / P0;
  else
    powerScale = 1;
  end

  output.fitobject = fitobject;
  output.powerScale = powerScale;
end

function fitobject = performInterpolation(L, T, I)
  [ X, Y, Z ] = prepareSurfaceData(L, T, I);
  X = [ X, Y ];
  Y = Z;

  type = fittype('linearinterp', 'numindep', 2);

  options = fitoptions(type);
  options.Normalize = 'on';

  fitobject = fit(X, Y, type, options);
end
