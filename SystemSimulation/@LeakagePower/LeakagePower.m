classdef LeakagePower < handle
  properties (Constant)
    %
    % The following constants are used to construct an instance
    % of the leakage model that, at the reference temperature,
    % produces the specified amount of the leakage power relative
    % to a given dynamic power profile.
    %
    PleakPdyn = 2 / 3;
    Tref = Utils.toKelvin(120);
  end

  properties (SetAccess = 'private')
    toString

    fit
    powerScale
  end

  methods
    function this = LeakagePower(varargin)
      options = Options(varargin{:});

      %
      % Prevent the dynamic power profile from affecting
      % the caching mechanism.
      %
      if options.has('dynamicPower')
        Pdyn = mean(options.dynamicPower(:));
        options.dynamicPower = [];
      else
        Pdyn = [];
      end

      this.toString = sprintf('%s(%s)', ...
        class(this), Utils.toString(options));

      filename = File.temporal( ...
        [ 'LeakagePower_', DataHash(this.toString), '.mat' ]);

      if File.exist(filename)
        load(filename);
      else
        fit = Utils.instantiate( ...
          options.fittingMethod, options, 'target', 'I');
        save(filename, 'fit', '-v7.3');
      end

      this.fit = fit;
      this.powerScale = 1;

      if isempty(Pdyn), return; end

      reference = struct;
      reference.T = this.Tref;
      this.powerScale = this.PleakPdyn * Pdyn / fit.compute(reference);
    end

    function P = compute(this, parameters)
      P = this.powerScale * this.fit.compute(parameters);
    end

    function plot(this)
      plot(this.fit);
    end
  end

  methods (Access = 'private')
    function description = recognize(this, name)
      description = struct;
      switch names{i}
      case 'T'
        description.notation = 'T';
        description.name = 'Temperature';
        description.units = 'K';
        description.nominal = Utils.toKelvin(45);
      case 'Leff'
        description.notation = 'Leff';
        description.name = 'The effective channel length';
        description.units = 'm';
        description.nominal = 45e-9;
      otherwise
        assert(false);
      end
    end
  end
end
