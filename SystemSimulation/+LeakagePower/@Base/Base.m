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

        output.Lmin = min(Lgrid(:));
        output.Lmax = max(Lgrid(:));
        output.Tmin = min(Tgrid(:));
        output.Tmax = max(Tgrid(:));

        save(filename, 'output', '-v7.3');
      end

      this.output = output;
    end

    function string = toString(this)
      string = sprintf('%s(%s)', ...
        class(this), this.options.filename);
    end
  end

  methods (Abstract)
    P = evaluate(this, L, T)
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
