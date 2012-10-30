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
    predict
    Ldata
    Tdata
    Idata
  end

  properties
    %
    % The effective channel length.
    %
    L

    %
    % The scaling coefficient from current to power.
    %
    C
  end

  methods
    function this = LeakagePower(varargin)
      [ data, options ] = Options.extract(varargin{:});
      this.initialize(options);

      this.L = this.Lnom;
      this.C = 1;

      if ~isempty(data)
        powerProfile = data{1};
        P0 = this.predict(this.Lnom, this.Tref);
        this.C = this.PleakPdyn * mean(powerProfile(:)) / P0;
      end
    end

    function P = evaluate(this, T)
      P = this.C * this.predict(this.L, T);
    end
  end

  methods (Access = 'private')
    [ predict, L, T, I ] = construct(this, options)

    function initialize(this, options)
      filename = [ class(this), '_', ...
        DataHash(string(options)), '.mat' ];

      if File.exist(filename);
        load(filename);
      else
        [ predict, Ldata, Tdata, Idata ] = this.construct(options);
        save(filename, 'predict', 'Ldata', 'Tdata', 'Idata');
      end

      this.predict = predict;
      this.Ldata = Ldata;
      this.Tdata = Tdata;
      this.Idata = Idata;
    end
  end
end
