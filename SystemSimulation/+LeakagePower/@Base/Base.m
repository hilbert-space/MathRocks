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
    toString

    output
    LRange
    TRange
    powerScale
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      %
      % Prevent the dynamic power profile from affecting
      % the caching mechanism.
      %
      if options.has('dynamicPower')
        Pdyn = options.dynamicPower;
        options.dynamicPower = [];
      else
        Pdyn = [];
      end

      this.toString = sprintf('%s(%s)', ...
        class(this), Utils.toString(options));

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
      this.powerScale = 1;

      if isempty(Pdyn), return; end

      Pmean = this.PleakPdyn * mean(Pdyn(:));
      P0 = this.evaluate(output, this.Lnom, this.Tref);
      this.powerScale = Pmean / P0;
    end

    function P = compute(this, L, T)
      P = this.powerScale * this.evaluate(this.output, L, T);
    end
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
    I = evaluate(this, output, L, T)
  end
end
