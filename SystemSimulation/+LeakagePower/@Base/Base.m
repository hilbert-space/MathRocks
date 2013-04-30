classdef Base < handle
  properties (Constant)
    %
    % The nominal value of the channel length.
    %
    Lnom = 45e-9;

    %
    % The following constants are used to construct an instance
    % of the leakage model that produces `PleakPdyn' portion
    % of the given dynamic power at temperature `Tref'.
    %
    PleakPdyn = 2 / 3;
    Tref = Utils.toKelvin(120);
  end

  properties (SetAccess = 'private')
    evaluate

    Ldata
    Tdata
    Idata

    stats
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      data = dlmread(options.filename, '\t', 1, 0);

      this.Ldata = data(:, 1);
      this.Tdata = Utils.toKelvin(data(:, 2));
      this.Idata = data(:, 3);

      filename = File.temporal([ 'LeakagePower_', ...
        DataHash(Utils.toString(options)), '.mat' ]);

      if File.exist(filename);
        load(filename);
      else
        [ evaluate, stats ] = this.construct( ...
          this.Ldata, this.Tdata, this.Idata, options);
        save(filename, 'evaluate', 'stats', '-v7.3');
      end

      this.evaluate = evaluate;
      this.stats = stats;
    end
  end

  methods (Abstract, Access = 'protected')
    [ evaluate, stats ] = construct(this, Ldata, Tdata, Idata, options)
  end
end
