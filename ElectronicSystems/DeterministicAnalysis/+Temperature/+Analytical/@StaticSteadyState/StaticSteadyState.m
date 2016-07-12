classdef StaticSteadyState < Temperature.Analytical.Base
  properties (SetAccess = 'protected')
    %
    %   X = -A^(-1) * B * P
    %   Q = C * X + D * P + Qamb
    %     = -C * A^(-1) * B * P + D * P + Qamb
    %     = (-C * A^(-1) * B + D) * P + Qamb
    %     = R * P + Qamb
    %
    R

    maximalTemperature
    errorMetric
    errorThreshold
    iterationLimit
  end

  methods
    function this = StaticSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Base(options);

      %
      % A^(-1) = (U * L * V)^(-1)
      %        = V^(-1) * L^(-1) * U^(-1)
      %        = U * L^(-1) * V
      %
      invA = this.U * diag(1 ./ this.L) * this.V;

      this.R = -this.C * invA * this.B + this.D;

      this.maximalTemperature = options.get( ...
        'maximalTemperature', Utils.toKelvin(450));
      this.errorMetric = options.get('errorMetric', 'NRMSE');
      this.errorThreshold = options.get('errorThreshold', 0.01);
      this.iterationLimit = options.get('iterationLimit', 20);
    end
  end
end
