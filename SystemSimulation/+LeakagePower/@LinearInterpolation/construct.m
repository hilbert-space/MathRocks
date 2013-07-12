function output = construct(this, Ldata, Tdata, Idata, options)
  LCount = options.get('LCount', 101);
  TCount = options.get('TCount', 101);

  readLCount = length(unique(Ldata));
  readTCount = length(unique(Tdata));

  LDivision = round(readLCount / LCount);
  TDivision = round(readTCount / TCount);

  LIndex = 1:LDivision:readLCount;
  TIndex = 1:TDivision:readTCount;

  Lgrid = reshape(Ldata, readTCount, readLCount);
  Tgrid = reshape(Tdata, readTCount, readLCount);
  Igrid = reshape(Idata, readTCount, readLCount);

  assert(size(unique(Lgrid, 'rows'), 1) == 1);
  assert(size(unique(Tgrid', 'rows'), 1) == 1);

  Lgrid = Lgrid(TIndex, LIndex);
  Tgrid = Tgrid(TIndex, LIndex);
  Igrid = Igrid(TIndex, LIndex);

  output.F = griddedInterpolant(Lgrid', Tgrid', Igrid', 'linear', 'none');

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = output.F(this.Lnom, this.Tref);
    output.powerScale = Pmean / P0;
  else
    output.powerScale = 1;
  end

  output.Lmin = min(Ldata);
  output.Lmax = max(Ldata);
  output.Tmin = min(Tdata);
  output.Tmax = max(Tdata);
end
