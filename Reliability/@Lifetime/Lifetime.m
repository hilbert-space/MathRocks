classdef Lifetime < handle
  %
  % References:
  %
  % [1] Failure Mechanisms and Models for Semiconductor Devices
  % [2] System-Level Reliability Modeling for MPSoCs
  % [3] http://www.siliconfareast.com/activation-energy.htm
  % [4] http://rel.intersil.com/docs/rel/calculation_of_semiconductor_failure_rates.pdf
  % [5] http://en.wikipedia.org/wiki/Boltzmann_constant
  %
  properties
    %
    % Sampling interval of temperature profiles
    %
    samplingInterval = 1e-3

    %
    % Peak threshold of local minima and maxima (for the cycle counting)
    %
    peakThreshold = 2; % K

    %
    % The rest is about the Coffin-Manson equation [1]:
    %
    % Nf = C0 * (dT - dT0)^(-q).
    %
    % More precisely, we rely on a variation of this equation
    % wherein the Arrhenius term is included [2]:
    %
    % Ntc = Atc * (dT - dT0)^(-q) * exp(Eatc / (k * Tmax)).
    %

    %
    % Coffin-Manson exponent [1]
    %
    q = 6; % from 6 to 9 for brittle fracture
           % (Si and dielectrics: SiO2, Si3N4)

    %
    % Portion of the temperature range in the elastic region [1]
    %
    dT0 = 0;

    %
    % Activation energy [3], [4]
    %
    Eatc = 0.5; % eV, depends on particular failure mechanism and
                %     material involved, typically ranges from
                %     0.5 up to 0.7

    %
    % Boltzmann constant [5]
    %
    k = 8.61733248e-5; % eV/K

    %
    % Shape parameter for the Weibull distribution
    %
    beta = 2;

    %
    % Empirically determined constant
    %
    Atc = 1e5;
  end

  methods
    function this = Lifetime(varargin)
      options = Options(varargin{:});

      names = properties(options);
      for i = 1:length(names)
        this.(names{i}) = options.(names{i});
      end

      this.Atc = this.calculateAtc;
    end

    function [ totalMTTF, output ] = predict(this, T, output)
      %
      % How it works?
      %
      % Everything is under the assumption that the failure rate
      % follows a Weibull distribution.
      %
      % Let n be the number of processing elements (PEs).
      % Assume the failure rates of the PEs are independent and
      % any failure causes the whole system to fail. Thus,
      %
      % R(t) = prod_i R_i(t)
      %
      % Now,
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
      % wherein the eta parameter stays constant (eta_ij).
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
      % distribution of the (ij)th time interval. Hence,
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
      % Assuming a particular failure mechanism, namely, thermal cycling
      % fatigue, we compute the MTTF theta_ij (as if this particular cycle
      % was the only one damaging the system) as follows:
      %
      % theta_ij = N_ij * dt_ij
      %
      % where N_ij is the number of cycles to failure, and dt_ij stands
      % for the duration of the cycle (it is also the period wherein
      % the eta_ij parameter is constant).
      %
      % Finally,
      %
      % Theta  = tau / (sum_i (sum_j (1 / N_ij))^beta)^(1 / beta).
      %

      [ processorCount, stepCount, profileCount ] = size(T);
      T = permute(T, [ 3, 2, 1 ]);

      period = stepCount * this.samplingInterval;

      if nargin > 2
        peakIndex  = output.peakIndex;
        cycleIndex = output.cycleIndex;
        cycles     = output.cycles;
      else
        peakIndex  = cell(processorCount, 1);
        cycleIndex = cell(processorCount, 1);
        cycles     = cell(processorCount, 1);
      end

      damage = zeros(processorCount, profileCount);

      factor = zeros(1, profileCount);
      for i = 1:processorCount
        if nargin > 2
          N = this.calculateCyclesToFailure(T(:, :, i), ...
            peakIndex{i}, cycleIndex{i});
        else
          [ N, peakIndex{i}, cycleIndex{i}, cycles{i} ] = ...
            this.calculateCyclesToFailure(T(:, :, i));
        end

        %
        % NOTE: The enumerator is not standard; here
        % we are trying to account for full and half cycles.
        %
        damage(i, :) = sum(repmat(cycles{i}, profileCount, 1) ./ N, 2);

        factor = factor + damage(i, :).^this.beta;
      end

      totalDamage = factor.^(1 / this.beta);
      totalMTTF = period ./ totalDamage;

      if nargout < 2, return; end

      output.peakIndex = peakIndex;
      output.cycleIndex = cycleIndex;
      output.cycles = cycles;

      output.damage = damage;
      output.MTTF = period ./ damage;

      output.totalDamage = totalDamage;
      output.totalMTTF = totalMTTF;

      output.processorCount = processorCount;
      output.stepCount = stepCount;

      output.beta = this.beta;
      output.samplingInterval = this.samplingInterval;
    end
  end

  methods (Access = 'private')
    function [ N, peakIndex, cycleIndex, cycles ] = ...
      calculateCyclesToFailure(this, T, peakIndex, cycleIndex)

      if nargin < 4
        [ peakIndex, extrema ] = Utils.detectPeaks(T(1, :), this.peakThreshold);
        [ cycleIndex, cycles ] = Utils.detectCycles(extrema);
      end

      if isempty(cycleIndex)
        N = zeros(size(T, 1), 0);
        return;
      end

      T = T(:, peakIndex);
      T = cat(3, T(:, cycleIndex(1, :)), T(:, cycleIndex(2, :)));

      dT = abs(T(:, :, 1) - T(:, :, 2)) - this.dT0;
      dT(dT < 0) = 0;

      Tmax = max(T, [], 3);

      %
      % Number of cycles to failure for each stress level [2]
      %
      N = this.Atc .* dT.^(-this.q) .* exp(this.Eatc ./ (this.k * Tmax));

      %
      % NOTE: If the temperature difference is zero, there is no damage.
      % Consequently, the number of cycles to failure should be infinite.
      % However, in this case, N turns to zero. Let us account for this.
      %
      N(N == 0) = Inf;
    end

    function Atc = calculateAtc(this)
      %
      % Let us assume that a system running an application
      % having a period of...
      %
      totalTime = 1; % s
      %
      % and producing...
      %
      cycleCount = 10;
      %
      % equal thermal cycles with the average temperature of...
      %
      Tavg = Utils.toKelvin(80); % K
      %
      % and the temperature difference of...
      %
      dT = 20; % K
      %
      % has the mean time to failure of...
      %
      MTTF = 20 * 365 * 24 * 60 * 60; % s

      Tmax = Tavg + dT / 2;
      factor = cycleCount * (dT - this.dT0)^this.q * ...
        exp(-this.Eatc / (this.k * Tmax));
      Atc = MTTF * factor / totalTime;
    end
  end
end
