classdef MonteCarlo < TemperatureVariation.Base
  methods
    function this = MonteCarlo(varargin)
      options = Options(varargin{:});

      temperatureOptions = options.temperatureOptions.clone; % use a copy
      if ~isempty(temperatureOptions.get('reduceModelOrder', []))
        warning('Monte Carlo: turning off the model order reduction.');
        temperatureOptions.remove('reduceModelOrder');
      end
      if temperatureOptions.get('algorithm', 1) >= 3
        warning('Monte Carlo: switching the first version of the algorithm.');
        temperatureOptions.algorithm = 1;
      end
      options.temperatureOptions = temperatureOptions;

      processOptions = options.processOptions.clone; % use a copy
      names = fieldnames(processOptions.parameters);
      for i = 1:length(names)
        if processOptions.parameters.(names{i}).reductionThreshold < 1
          warning([ 'Monte Carlo: turning off the process ', ...
            'dimension reduction for ', names{i}, '.' ]);
          processOptions.parameters.(names{i}).reductionThreshold = 1;
        end
      end
      options.processOptions = processOptions;

      this = this@TemperatureVariation.Base(options);
    end

    function output = compute(this, Pdyn)
      filename = sprintf('%s_%s.mat', class(this), ...
        DataHash({ Pdyn, this.toString }));

      if File.exist(filename)
        fprintf('Monte Carlo: loading %d samples from "%s"...\n', ...
          this.surrogate.sampleCount, filename);
        load(filename);
      else
        fprintf('Monte Carlo: collecting %d samples...\n', ...
          this.surrogate.sampleCount);

        time = tic;
        output = this.simulate(Pdyn);
        time = toc(time);

        save(filename, 'output', 'time', '-v7.3');
      end

      fprintf('Monte Carlo: done in %.2f seconds.\n', time);
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
      output.data = this.postprocess(output, output.data);
    end
  end
end
