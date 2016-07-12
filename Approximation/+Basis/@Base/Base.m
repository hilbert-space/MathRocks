classdef Base < handle
  properties (SetAccess = 'private')
    support
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.support = options.get('support', [0, 1]);
    end
  end
end
