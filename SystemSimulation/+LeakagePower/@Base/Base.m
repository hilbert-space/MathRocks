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

  properties (SetAccess = 'protected')
    options
    output
    LRange
    TRange
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.options = options;

      filename = File.temporal([ 'LeakagePower_', ...
        DataHash({ class(this), Utils.toString(options) }), '.mat' ]);

      if File.exist(filename);
        load(filename);
      else
        [ Lgrid, Tgrid, Igrid ] = Utils.loadLeakageData(options);
        output = this.construct(Lgrid, Tgrid, Igrid, options);

        LRange = [ min(Lgrid(:)), max(Lgrid(:)) ];
        TRange = [ min(Tgrid(:)), max(Tgrid(:)) ];

        save(filename, 'output', 'LRange', 'TRange', '-v7.3');
      end

      this.output = output;
      this.LRange = LRange;
      this.TRange = TRange;
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        Utils.toString(this.options));
    end
  end

  methods (Abstract)
    P = evaluate(this, L, T)
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
