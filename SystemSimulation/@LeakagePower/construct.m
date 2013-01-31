function [ evaluate, Ldata, Tdata, Idata, stats ] = construct(varargin)
  options = Options(varargin{:});

  filename = File.temporal([ 'LeakagePower_', ...
    DataHash(Utils.toString(options)), '.mat' ]);

  if File.exist(filename);
    load(filename);
  else
    [ logI, Lsym, Tsym, Ldata, Tdata, Idata, stats ] = LeakagePower.fit(options);
    save(filename, 'logI', 'Lsym', 'Tsym', ...
      'Ldata', 'Tdata', 'Idata', 'stats', '-v7.3');
  end

  if options.has('dynamicPower')
    Lnom  = LeakagePower.Lnom;
    Tref  = LeakagePower.Tref;
    Pmean = LeakagePower.PleakPdyn * mean(options.dynamicPower(:));

    P0 = exp(double(subs(subs(logI, Lsym, Lnom), Tsym, Tref)));
    powerScale = Pmean / P0;
  else
    powerScale = 1;
  end

  [ arguments, body ] = Utils.toFunctionString(logI, Lsym, Tsym);
  string = sprintf('@(%s)%s*exp(%s)', ...
    arguments, num2string(powerScale, 'longg'), body);

  evaluate = str2func(string);
end
