classdef LeakagePower < handle
  properties (Constant)
    %
    % The following constants are used to construct an instance
    % of the leakage model that, at the reference temperature,
    % produces the specified amount of the leakage power relative
    % to a given dynamic power profile.
    %
    PleakPdyn = 2 / 3;
  end

  properties (SetAccess = 'private')
    toString

    parameterNames
    parameterCount

    reference
  end

  properties (Access = 'private')
    fit
    linearization
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

      this.parameterNames = fit.parameterNames;
      this.parameterCount = fit.parameterCount;

      this.fit = fit;
      this.powerScale = 1;

      %
      % Compute the reference values of the parameters.
      %
      this.reference = struct;
      for i = 1:this.parameterCount
        this.reference.(this.parameterNames{i}) = ...
          this.identify(this.parameterNames{i});
      end

      if isempty(Pdyn), return; end

      this.powerScale = this.PleakPdyn * Pdyn / ...
        fit.compute(this.reference);
    end

    function P = compute(this, varargin)
      if isempty(this.linearization)
        P = this.powerScale * this.fit.compute(varargin{:});
      else
        P = this.powerScale * this.linearization(varargin{:});
      end
    end

    function varargout = assign(this, varargin)
      varargout = cell(1, nargout);
      [ varargout{:} ] = this.fit.assign( ...
        varargin{:}, 'reference', this.reference);
    end

    function result = isLinearized(this)
      result = ~isempty(this.linearization);
    end

    function plot(this, varargin)
      plot(this.fit, varargin{:});
    end

    function result = parameterSweeps(this)
      result = this.fit.parameterSweeps;
    end
  end

  methods (Access = 'private')
    function reference = identify(this, parameter)
      switch parameter
      case 'T'
        reference = Utils.toKelvin(120);
      case 'Leff'
        reference = 45e-9;
      case 'Tox'
        reference = 1.25e-9;
      otherwise
        assert(false);
      end
    end
  end
end
