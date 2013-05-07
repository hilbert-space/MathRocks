function output = construct(this, Ldata, Tdata, Idata, options)
  Lcount = length(unique(Ldata));
  Tcount = length(unique(Tdata));

  output.Lgrid = reshape(Ldata, Tcount, Lcount);
  output.Tgrid = reshape(Tdata, Tcount, Lcount);
  output.Igrid = reshape(Idata, Tcount, Lcount);

  assert(size(unique(output.Lgrid, 'rows'), 1) == 1);
  assert(size(unique(output.Tgrid', 'rows'), 1) == 1);

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = interpolate(output.Lgrid, output.Tgrid, output.Igrid, ...
      this.Lnom, this.Tref);
    output.powerScale = Pmean / P0;
  else
    output.powerScale = 1;
  end
end
