function output = construct(this, Ldata, Tdata, Idata, options)
  Lcount = length(unique(Ldata));
  Tcount = length(unique(Tdata));

  Lgrid = reshape(Ldata, Tcount, Lcount);
  Tgrid = reshape(Tdata, Tcount, Lcount);
  Igrid = reshape(Idata, Tcount, Lcount);

  assert(size(unique(Lgrid, 'rows'), 1) == 1);
  assert(size(unique(Tgrid', 'rows'), 1) == 1);

  output.F = griddedInterpolant(Lgrid', Tgrid', Igrid', 'linear', 'none');

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = output.F(this.Lnom, this.Tref);
    output.powerScale = Pmean / P0;
  else
    output.powerScale = 1;
  end
end
