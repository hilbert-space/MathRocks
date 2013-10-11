classdef Base < handle
  properties (SetAccess = 'protected')
    sampleCount
    process
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.sampleCount = options.get('sampleCount', 1e3);

      options = options.processOptions;
      names = fieldnames(options.parameters);
      for i = 1:length(names)
        %
        % NOTE: Although we modify the options here, they are a copy
        % of the original ones, which was created in the constructors
        % of the classes inheriting this base class.
        %
        if options.parameters.(names{i}).reductionThreshold < 1
          warning([ 'Monte Carlo: turning off the process ', ...
            'dimension reduction for ', names{i}, '.' ]);
          options.parameters.(names{i}).reductionThreshold = 1;
        end
      end

      this.process = ProcessVariation(options);
    end

    function [ Texp, output ] = estimate(this, Pdyn, varargin)
      %
      % NOTE: We always generate samples here, even though the futher
      % MC simulations might be cached. The reason is to advance the RNG
      % of MATLAB and have the same bahavior of the computations outside
      % this method.
      %
      parameters = this.process.sample(this.sampleCount);
      parameters = cellfun(@transpose, parameters, 'UniformOutput', false);
      parameters = this.process.assign(parameters);

      filename = sprintf('MonteCarlo_%s.mat', ...
        DataHash({ Pdyn, this.toString }));

      if File.exist(filename)
        fprintf('Monte Carlo: loading %d samples from "%s"...\n', ...
          this.sampleCount, filename);
        load(filename);
      else
        fprintf('Monte Carlo: collecting %d samples...\n', ...
          this.sampleCount);

        time = tic;
        Tdata = this.computeWithLeakage(Pdyn, parameters);

        I = squeeze(any(any(isnan(Tdata), 1), 2));
        Tdata(:, :, I) = [];

        Texp = mean(Tdata, 3);
        Tvar = var(Tdata, [], 3);
        Tdata = permute(Tdata, [ 3 1 2 ]);

        time = toc(time);

        save(filename, 'Texp', 'Tvar', 'Tdata', 'time', 'I', '-v7.3');
      end

      fprintf('Monte Carlo: done in %.2f seconds.\n', time);

      nanCount = sum(I);
      if nanCount > 0
        warning('Monte Carlo: %d samples have been rejected due to NaNs.', ...
          nanCount);
      end

      output.Pdyn = Pdyn;
      output.Tvar = Tvar;
      output.Tdata = Tdata;
      output.time = time;
    end

    function Tdata = evaluate(this, output, rvs)
      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = cellfun(@transpose, parameters, 'UniformOutput', false);
      parameters = this.process.assign(parameters);
      Tdata = permute(this.computeWithLeakage( ...
        output.Pdyn, parameters), [ 3 1 2 ]);
    end

    function options = computeStatistics(this, varargin)
      options = Options( ...
        'functionEvaluations', this.sampleCount);
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        String(struct( ...
          'sampleCount', this.sampleCount, ...
          'process', this.process)));
    end
  end
end
