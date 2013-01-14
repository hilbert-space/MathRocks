classdef Fredholm < KarhunenLoeve.Base
  methods
    function this = Fredholm(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ functions, values ] = construct(this, options)
  end
end
