classdef PolynomialChaos < TemperatureVariation.Base
  methods
    function this = PolynomialChaos(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.serve(Pdyn, rvs));
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

      if options.get('anisotropic', false)
        anisotropy = this.process.importance;
        for i = 1:this.process.parameterCount
          anisotropy{i} = anisotropy{i}(:) / max(anisotropy{i}(:));
        end
        anisotropy = transpose(cell2mat(anisotropy(:)));
      else
        anisotropy = [];
      end

      surrogate = PolynomialChaos('inputCount', sum(this.process.dimensions), ...
        'distribution', distribution, 'anisotropy', anisotropy, options);
    end

    function T = serve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = this.process.assign(parameters);

      T = this.temperature.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
