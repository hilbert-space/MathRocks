classdef LeakagePower < handle
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
    toString

    evaluator
    Ldata
    Tdata
    Idata

    stats
  end

  properties
    %
    % The scaling coefficient from current to power.
    %
    C
  end

  methods
    function this = LeakagePower(varargin)
      [ data, options ] = Options.extract(varargin{:});
      this.toString = options.toString;
      this.initialize(options);

      this.C = 1;

      if ~isempty(data)
        powerProfile = data{1};
        P0 = this.evaluator(this.Lnom, this.Tref);
        this.C = this.PleakPdyn * mean(powerProfile(:)) / P0;
      end
    end

    function P = evaluate(this, L, T)
      P = this.C * this.evaluator(L, T);
    end
  end

  methods (Access = 'private')
    [ evaluator, Ldata, Tdata, Idata, stats ] = construct(this, options)

    function initialize(this, options)
      filename = File.temporal([ class(this), '_', ...
        DataHash(this.toString), '.mat' ]);

      if File.exist(filename);
        load(filename);
      else
        [ evaluator, Ldata, Tdata, Idata, stats ] = this.construct(options);
        save(filename, 'evaluator', 'Ldata', 'Tdata', 'Idata', ...
          'stats', '-v7.3');
      end

      this.evaluator = evaluator;
      this.Ldata = Ldata;
      this.Tdata = Tdata;
      this.Idata = Idata;
      this.stats = stats;
    end
  end
end
