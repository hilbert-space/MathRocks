classdef Base < handle
  properties (SetAccess = 'protected')
    %
    % The shape parameter for the Weibull distribution
    %
    beta = 2;

    samplingInterval % s
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.samplingInterval = options.samplingInterval;
    end

    function [ expectation, output ] = compute(this, T, output)
      %
      % How does it work?
      %
      % Everything is under the assumption that the time to failure
      % follows a Weibull distribution:
      %
      % T ~ Weibull(eta, beta).
      %
      % Denote the corresponding CDF by F(t | eta, beta). Then the
      % reliability function is
      %
      % R(t | eta, beta) = 1 - F(t | eta, beta) = exp{ -(t / eta)^beta }.
      %
      % Let n be the number of processing elements (PEs).
      % Assume the failure rates of the PEs are independent, and
      % any failure causes the failure of the whole system. Thus,
      %
      % R(t) = prod_i R_i(t).
      %
      % Each PE undergoes a number of stress levels. It can be shown that
      %
      % R_i(t) = exp{ -[ (t / tau) * sum_j (dt_ij / eta_ij) ]^beta }
      %        = exp{ -(t / eta_i)^beta }
      %
      % where
      %
      % eta_i  = tau / sum_j (dt_ij / eta_ij),
      %
      % tau is the period of the application, and the summation
      % under the exponentiation is over all the periods dt_ij
      % wherein the eta parameter (i.e., eta_ij) stays constant
      % (corresponds to one stress level).
      %
      % Consequently,
      %
      % R(t) = prod_i R_i(t)
      %      = exp{ -sum_i (t / eta_i)^beta }
      %      = exp{ -[ (sum_i (1 / eta_i)^beta)^(1 / beta) }^beta t^beta }
      %      = exp{ - (t / Eta)^beta }
      % where
      %
      % Eta  = 1 / (sum_i (1 / eta_i)^beta)^(1 / beta)
      %
      % Next, let theta_ij be the expectation of the Weibull
      % distribution corresponding to the (ij)th time interval. Hence,
      %
      % eta_ij = theta_ij / gamma(1 + 1 / beta),
      % eta_i  = tau / gamma(1 + 1 / beta) / sum_j (dt_ij / theta_ij), and
      % Eta    = tau / (sum_i (sum_j (dt_ij / theta_ij))^beta)^(1 / beta) / gamma(1 + 1 / beta).
      %
      % The overall MTTF is then
      %
      % Theta  = Eta * gamma(1 + 1 / beta)
      %        = tau / (sum_i (sum_j (dt_ij / theta_ij))^beta)^(1 / beta).
      %
      % Assuming a particular failure mechanism, we compute the MTTF
      % theta_ij as follows:
      %
      % theta_ij = N_ij * dt_ij
      %
      % where N_ij is the number of cycles to failure, and dt_ij stands
      % for the duration of the cycle (it is the period wherein the eta_ij
      % parameter is constant).
      %
      % Finally,
      %
      % Theta  = tau / (sum_i (sum_j (1 / N_ij))^beta)^(1 / beta).
      %
      [ processorCount, stepCount, profileCount ] = size(T);

      period = stepCount * this.samplingInterval;

      if nargin < 3
        output = this.partitionStress(T(:, :, 1));
      end

      partitions = output.partitions;
      weights = output.weights;

      damage = zeros(processorCount, profileCount);
      factor = zeros(1, profileCount);

      for i = 1:processorCount
        for j = 1:size(partitions{i}, 2)
          range = partitions{i}(1, j):partitions{i}(2, j);
          damage(i, :) = damage(i, :) + weights{i}(j) * ...
            this.computeDamage(shiftdim(T(i, range, :), 1));
        end
        factor = factor + damage(i, :).^this.beta;
      end

      totalDamage = factor.^(1 / this.beta);
      expectation = period ./ totalDamage;

      output.Eta = expectation ./ gamma(1 + 1 / this.beta);
      output.eta = period ./ damage ./ gamma(1 + 1 / this.beta);
    end
  end

  methods (Abstract, Access = 'protected')
    output = partitionStress(this, T)
    damage = computeDamage(this, T)
  end
end