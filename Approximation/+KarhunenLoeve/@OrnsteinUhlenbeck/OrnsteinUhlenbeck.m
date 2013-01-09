classdef OrnsteinUhlenbeck < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    correlationLength
  end

  methods
    function this = OrnsteinUhlenbeck(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end

    function C = calculate(this, s, t)
      if ndims(s) == 1
        m = length(s);
        n = length(t);
        [ s, t ] = meshgrid(s, t);
      else
        [ m, n ] = size(s);
      end

      s = s(:);
      t = t(:);

      C = exp(-abs(s - t) / this.correlationLength);
      C = reshape(C, [ m n ]);
    end
  end

  methods (Access = 'protected')
    [ values, functions ] = construct(this, options)
  end
end
