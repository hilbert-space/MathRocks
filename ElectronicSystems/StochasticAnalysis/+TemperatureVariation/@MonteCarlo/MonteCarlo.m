classdef MonteCarlo < TemperatureVariation.Base
  methods
    function this = MonteCarlo(varargin)
      options = Options(varargin{:});

      temperatureOptions = options.temperatureOptions.clone; % use a copy
      if ~isempty(temperatureOptions.get('modelOrderReduction', []))
        warning('Turning off the model order reduction.');
        temperatureOptions.remove('modelOrderReduction');
      end
      options.temperatureOptions = temperatureOptions;

      processOptions = options.processOptions.clone; % use a copy
      names = fieldnames(processOptions.parameters);
      for i = 1:length(names)
        if processOptions.parameters.(names{i}).reductionThreshold < 1
          warning([ 'Turning off the process dimension reduction for ', ...
            names{i}, '.' ]);
          processOptions.parameters.(names{i}).reductionThreshold = 1;
        end
      end
      options.processOptions = processOptions;

      this = this@TemperatureVariation.Base(options);
    end

    function output = compute(this, Pdyn)
      output = this.simulate(Pdyn);
    end
  end

  methods (Access = 'protected')
    function surrogate = configure(this, options)
      %
      % NOTE: For now, only one distribution.
      %
      distributions = this.process.distributions;
      distribution = distributions{1};
      for i = 2:this.process.parameterCount
        assert(distribution == distributions{i});
      end

      surrogate = MonteCarlo( ...
        'inputCount', sum(this.process.dimensions), ...
        'sampleCount', options.get('sampleCount', 1e4), ...
        'distribution', distribution);
    end

    function T = serve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = this.process.assign(parameters);

      T = this.temperature.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end

    function output = simulate(this, Pdyn)
      output = this.surrogate.construct(@(rvs) this.serve(Pdyn, rvs));
    end
  end
end
