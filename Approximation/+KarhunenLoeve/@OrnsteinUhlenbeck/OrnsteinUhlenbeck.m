classdef OrnsteinUhlenbeck < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    correlationLength
  end

  methods
    function this = OrnsteinUhlenbeck(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end

    function C = calculate(this, s, t)
      C = exp(-sum(abs(s - t), 1) / this.correlationLength);
    end
  end

  methods (Access = 'protected')
    [ functions, values ] = construct(this, options)
  end
end
