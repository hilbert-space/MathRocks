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
    evaluate
    L
    T
    I
  end

  methods
    function this = LeakagePower(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end
  end

  methods (Access = 'private')
    [ evaluate, L, T, I ] = construct(this, options)

    function initialize(this, options)
      filename = [ class(this), '_', ...
        DataHash(string(options)), '.mat' ];

      if File.exist(filename);
        load(filename);
      else
        [ evaluate, L, T, I ] = this.construct(options);
        save(filename, 'evaluate', 'L', 'T', 'I');
      end

      this.evaluate = evaluate;
      this.L = L;
      this.T = T;
      this.I = I;
    end
  end
end
