function output = construct(this, Ldata, Tdata, Idata, options)
  [ fitobject, expectation, deviation ] = ...
    performInterpolation(Ldata, Tdata, Idata);

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = expectation + deviation * sfun(fitobject, this.Lnom, this.Tref);
    powerScale = Pmean / P0;
  else
    powerScale = 1;
  end

  output.fitobject = fitobject;
  output.expectation = expectation;
  output.deviation = deviation;
  output.powerScale = powerScale;
end

function [ fitobject, expectation, deviation ] = performInterpolation(L, T, I)
  [ X, Y, Z ] = prepareSurfaceData(L, T, I);
  X = [ X, Y ];
  Y = Z;

  [ X, expectation, deviation ] = curvefit.normalize(X);

  fitobject = fit(X, Y, 'linearinterp');
end
