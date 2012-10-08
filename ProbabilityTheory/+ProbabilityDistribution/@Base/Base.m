classdef Base < handle
  properties (SetAccess = 'protected')
    mu
    sigma
  end

  methods
    function this = Base()
    end

    function plot(this, varargin)
      options = Options(varargin{:});
      data = this.sample(options.get('samples', 1e3), 1);
      Stats.observe(data, 'draw', true, options);
    end
  end

  methods (Abstract)
    data = sample(this, samples, dimension)
    data = apply(this, data)
    data = invert(this, data)
  end
end
