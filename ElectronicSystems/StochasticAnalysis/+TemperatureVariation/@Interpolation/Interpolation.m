classdef Interpolation < TemperatureVariation.Base
  methods
    function this = Interpolation(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.surve(Pdyn, rvs), numel(Pdyn));
    end

    function stats = analyze(~, ~)
      stats.expectation = NaN;
      stats.variance = NaN;
    end

    function data = sample(this, output, sampleCount)
      parameters = this.process.sample(sampleCount);
      parameters = this.process.normalize(parameters);
      parameters = cell2mat(parameters);

      data = this.surrogate.evaluate(output, parameters);
      data = this.postprocess(output, data);
    end

    function data = evaluate(this, output, rvs, ~)
      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters, true); % uniform
      parameters = this.process.normalize(parameters);
      parameters = cell2mat(parameters);

      data = this.surrogate.evaluate(output, parameters);
      data = this.postprocess(output, data);
    end
  end

  methods (Access = 'protected')
    function surrogate = configure(this, options)
      %
      % NOTE: For now, only one distribution and only beta.
      %
      distributions = this.process.distributions;
      distribution = distributions{1};
      for i = 2:this.process.parameterCount
        assert(distribution == distributions{i});
      end

      assert(isa(distribution, 'ProbabilityDistribution.Beta'));

      surrogate = Utils.instantiate( ...
         String.join('.', 'Interpolation', 'Hierarchical', options.method), ...
        'inputCount', this.process.parameterCount * this.processorCount, ...
        'relativeTolerance', 1e-2, ...
        'absoluteTolerance', 1e-3, ...
        'maximalLevel', 10, options);
    end

    function T = surve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = mat2cell(rvs, sampleCount, ...
        this.processorCount * ones(1, this.process.parameterCount));
      parameters = this.process.denormalize(parameters);
      parameters = this.process.assign(parameters);

      T = this.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
