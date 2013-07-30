classdef Base < handle
  properties (SetAccess = 'protected')
    process
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      if options.processOptions.reductionThreshold < 1
        warning('Monte Carlo: turning off the process dimension reduction.');
      end

      this.process = ProcessVariation.(options.processModel)( ...
        options.processOptions, 'reductionThreshold', 1);
    end

    function [ Texp, output ] = estimate(this, Pdyn, options)
      verbose = options.get('verbose', false);

      sampleCount = options.get('sampleCount', 1e3);

      %
      % NOTE: We always generate samples of V, even though the futher
      % MC simulations might be cached. The reason is to advance the RNG
      % of MATLAB and have the same bahavior of the computations outside
      % this method.
      %
      V = transpose(this.process.sample(sampleCount));

      filename = options.get('filename', []);
      if isempty(filename)
        filename = sprintf('MonteCarlo_%s.mat', ...
          DataHash({ Pdyn, this.toString, sampleCount }));
      end

      if File.exist(filename)
        if verbose
          fprintf('Monte Carlo: using cached data in "%s"...\n', filename);
        end
        load(filename);
      else
        if verbose
          fprintf('Monte Carlo: running %d simulations...\n', sampleCount);
        end

        time = tic;

        Tdata = this.computeWithLeakage(Pdyn, Options(options, 'V', V));

        Texp = mean(Tdata, 3);
        Tvar = var(Tdata, [], 3);
        Tdata = permute(Tdata, [ 3 1 2 ]);

        time = toc(time);

        save(filename, 'Texp', 'Tvar', 'Tdata', 'time', '-v7.3');
      end

      if verbose
        fprintf('Monte Carlo: simulation time %.2f s (%d samples).\n', ...
          time, sampleCount);
      end

      output.Pdyn = Pdyn;
      output.Tvar = Tvar;
      output.Tdata = Tdata;
      output.time = time;
    end

    function Tdata = evaluate(this, output, rvs, varargin)
      V = transpose(this.process.evaluate(rvs));
      Tdata = this.computeWithLeakage( ...
        output.Pdyn, Options(varargin{:}, 'V', V));
      Tdata = permute(Tdata, [ 3 1 2 ]);
    end

    function string = toString(this)
      string = Utils.toString(this.process);
    end
  end
end
