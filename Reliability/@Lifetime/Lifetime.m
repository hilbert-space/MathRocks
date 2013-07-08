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

    function [ totalMTTF, output ] = predict(this, T)
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

      [ processorCount, stepCount ] = size(T);

      period = stepCount * this.samplingInterval;

      damage = zeros(processorCount, 1);
      peakIndex = cell(processorCount, 1);
      cycles = cell(processorCount, 1);

      factor = 0;
      for i = 1:processorCount
        [ N, peaks, cycles{i} ] = this.calculateCyclesToFailure(T(i, :));
        peakIndex{i} = peaks(:, 1);

        %
        % NOTE: The enumerator is not standard; here
        % we are trying to account for full and half cycles.
        %
        damage(i) = sum(cycles{i} ./ N);

        factor = factor + damage(i)^this.beta;
      end

      totalDamage = factor^(1 / this.beta);
      totalMTTF = period / totalDamage;

      if nargout < 2, return; end

      output.damage = damage;
      output.peakIndex = peakIndex;
      output.cycles = cycles;
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
    function [ N, peaks, cycles ] = calculateCyclesToFailure(this, T)
      [ maxPeaks, minPeaks ] = peakdet(T, this.peakThreshold);
      peaks = [ maxPeaks; minPeaks ];
      [ ~, I ] = sort(peaks(:, 1));
      peaks = peaks(I, :);

      if size(peaks, 1) == 0
        N = [];
        peaks = [];
        cycles = [];
        return;
      end

      rain = rainflow(peaks(:, 2));

      %
      % NOTE: The encoding is the following:
      %
      % rain(1, :) - amplitudes,
      % rain(2, :) - mean values, and
      % rain(3, :) - half or complete (0.5 or 1.0).
      %

      dT     = 2 * rain(1, :);
      Tmax   = rain(2, :) + rain(1, :);
      cycles = rain(3, :);

      %
      % Number of cycles to failure for each stress level [2]
      %
      N = this.Atc .* max(0, dT - this.dT0).^(-this.q) .* ...
        exp(this.Eatc ./ (this.k * Tmax));

      %
      % NOTE: If the temperature difference is zero, there is no damage.
      % Consequently, the number of cycles to failure should be infinite.
      % However, in this case, N turns to zero. Let us account for this.
      %
      N(N == 0) = Inf;
    end

    function Atc = calculateAtc(this)
      %
      % Let us assume to have the mean time to failure equal to ten years
      % with the average temperature of 60 C, the total application period
      % of one second, and ten equal cycles of 10 C.
      %

      mttf = 10 * 365 * 24 * 60 * 30; % s, 20 years
      Tavg = Utils.toKelvin(60); % K
      totalTime = 1; % s
      m = 10; % Number of cycles
      dT = 10; % K
      Tmax = Tavg + dT / 2;

      factor = m * (dT - this.dT0)^this.q * ...
        exp(-this.Eatc / (this.k * Tmax));

      Atc = mttf * factor / totalTime;
    end
  end
end
