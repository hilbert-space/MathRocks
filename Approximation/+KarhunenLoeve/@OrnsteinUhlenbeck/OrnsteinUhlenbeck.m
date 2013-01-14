classdef OrnsteinUhlenbeck < KarhunenLoeve.Base
  methods
    function this = OrnsteinUhlenbeck(varargin)
      options = Options(varargin{:});
      kernel = @(s, t) exp(-abs(s - t) / options.correlationLength);
      options.set('kernel', kernel);
      this = this@KarhunenLoeve.Base(options);
    end
  end

  methods (Access = 'protected')
    [ functions, values ] = construct(this, options)
  end
end
