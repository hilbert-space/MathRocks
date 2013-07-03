classdef Transient < Temperature.MonteCarlo.Base
  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.MonteCarlo.Base(options);
      this.temperature = Temperature.Numerical.Transient( ...
        options.temperatureOptions);
    end
  end
end
