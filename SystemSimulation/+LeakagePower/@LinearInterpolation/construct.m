function output = construct(this, Lgrid, Tgrid, Igrid, options)
  output.F = griddedInterpolant( ...
    Lgrid.', Tgrid.', Igrid.', 'linear', 'none');

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = output.F(this.Lnom, this.Tref);
    output.powerScale = Pmean / P0;
  else
    output.powerScale = 1;
  end
end
