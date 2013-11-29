classdef ThermalCycling < Fatigue.Base
  %
  % References:
  %
  % [1] Failure Mechanisms and Models for Semiconductor Devices
  % [2] System-Level Reliability Modeling for MPSoCs
  % [3] http://www.siliconfareast.com/activation-energy.htm
  % [4] http://rel.intersil.com/docs/rel/calculation_of_semiconductor_failure_rates.pdf
  % [5] http://en.wikipedia.org/wiki/Boltzmann_constant
  %
  properties (SetAccess = 'protected')
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
    % Empirically determined constant
    %
    Atc

    %
    % The tolerance of the thermal cycle detection
    %
    threshold
  end

  methods
    function this = ThermalCycling(varargin)
      options = Options(varargin{:});

      this = this@Fatigue.Base(options);

      this.Atc = this.computeAtc;
      this.threshold = options.get('threshold', 2); % K
    end
  end

  methods (Access = 'protected')
    function output = partitionStress(this, T)
      output = struct;
      [ output.partitions, output.weights, output.extrema ] = ...
        Utils.detectCycles(T, this.threshold);
    end

    function damage = computeDamage(this, T)
      Tmax = max(T, [], 1);
      Tmin = min(T, [], 1);

      dT = max(0, (Tmax - Tmin) - this.dT0);

      %
      % Number of cycles to failure [2]
      %
      N = this.Atc * dT.^(-this.q) .* exp(this.Eatc ./ (this.k * Tmax));

      %
      % NOTE: If the temperature difference is zero, there is no damage.
      % Consequently, the number of cycles to failure should be infinite.
      % However, in this case, N turns to zero. Let us account for this.
      %
      N(N == 0) = Inf;

      damage = 1 ./ N;
    end

    function Atc = computeAtc(this)
      %
      % Let us assume that a system running an application
      % having a period of...
      %
      totalTime = 1; % s
      %
      % and producing...
      %
      cycleCount = 1;
      %
      % equal thermal cycles with the average temperature of...
      %
      Tavg = Utils.toKelvin(70); % K
      %
      % and the temperature difference of...
      %
      dT = 40; % K
      %
      % has the mean time to failure of...
      %
      MTTF = 20 * 365 * 24 * 60 * 60; % s

      Tmax = Tavg + dT / 2;
      factor = cycleCount * max(0, dT - this.dT0)^this.q * ...
        exp(-this.Eatc / (this.k * Tmax));

      assert(factor > 0);

      Atc = MTTF * factor / totalTime;
    end
  end
end
