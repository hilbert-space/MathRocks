classdef LeakagePower < handle
  properties (SetAccess = 'protected')
    parameterNames
    parameterCount

    reference
    powerScale

    surrogate
    evaluate

    toString
  end

  methods
    function this = LeakagePower(varargin)
      options = Options(varargin{:}, 'targetName', 'Ileak');

      referencePower = options.fetch('referencePower', NaN); % do not cache

      this.toString = sprintf('%s(%s)', class(this), String(options));

      this.parameterNames = fieldnames(options.parameters);
      this.parameterCount = length(this.parameterNames);

      %
      % Compute the reference values of the parameters
      %
      this.reference = cell(1, this.parameterCount);
      for i = 1:this.parameterCount
        this.reference{i} = ...
          options.parameters.(this.parameterNames{i}).reference;
      end

      %
      % Load or construct the surrogate
      %
      filename = File.temporal([ class(this), '_', ...
        DataHash(this.toString), '.mat' ]);

      if File.exist(filename)
        load(filename);
      else
        surrogate = Fitting(options);
        save(filename, 'surrogate', '-v7.3');
      end

      assert(this.parameterCount == surrogate.parameterCount);
      for i = 1:this.parameterCount
        assert(strcmp(this.parameterNames{i}, ...
          surrogate.parameterNames{i}));
      end

      this.surrogate = surrogate;

      %
      % Compute the power scale
      %
      if isnan(referencePower)
        powerScale = 1;
      else
        powerScale = referencePower / ...
          surrogate.evaluate(this.reference{:});
      end
      this.powerScale = powerScale;

      %
      % Construct the evaluation function
      %
      this.evaluate = @(varargin) ...
        powerScale * surrogate.evaluate(varargin{:});
    end

    function [ parameters, dimensions, index ] = ...
      assign(this, assignments, dimensions)

      [ parameters, dimensions, index ] = this.surrogate.assign( ...
        assignments, dimensions, this.reference);
    end

    function plot(this, varargin)
      plot(this.surrogate, varargin{:});
    end

    function result = parameterSweeps(this)
      result = this.surrogate.parameterSweeps;
    end
  end
end
