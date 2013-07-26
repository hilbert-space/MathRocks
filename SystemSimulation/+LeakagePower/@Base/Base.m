classdef Base < handle
  properties (Constant)
    %
    % The nominal values of the leakage parameters. Right now
    % it is only the effective channel length.
    %
    Vnom = 45e-9;

    %
    % The following constants are used to construct an instance
    % of the leakage model that, at the reference temperature,
    % produces the specified amount of the leakage power relative
    % to a given dynamic power profile.
    %
    PleakPdyn = 2 / 3;
    Tref = Utils.toKelvin(120);
  end

  properties (SetAccess = 'protected')
    toString

    output
    VRange
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
        [ V, T, I ] = Utils.loadLeakageData(options);
        output = this.construct(V, T, I, options);

        VRange = [ min(V(:)), max(V(:)) ];
        TRange = [ min(T(:)), max(T(:)) ];

        save(filename, 'output', 'VRange', 'TRange', '-v7.3');
      end

      this.output = output;
      this.VRange = VRange;
      this.TRange = TRange;
      this.powerScale = 1;

      if isempty(Pdyn), return; end

      this.powerScale = this.PleakPdyn * mean(Pdyn(:)) / ...
        this.evaluate(output, this.Vnom, this.Tref);
    end

    function P = compute(this, V, T)
      P = this.powerScale * this.evaluate(this.output, V, T);
    end
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, V, T, I, options)
    I = evaluate(this, output, V, T)
  end
end
