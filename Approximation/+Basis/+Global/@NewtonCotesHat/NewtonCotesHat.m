classdef NewtonCotesHat < ...
  Basis.Base.NewtonCotesHat & ...
  Basis.Global.Base

  properties (SetAccess = 'private')
    maximalLevel
    level
    Yij
    Li
    Mi
    Ni
  end

  methods
    function this = NewtonCotesHat(varargin)
      options = Options(varargin{:});

      this = this@Basis.Base.NewtonCotesHat(options);
      this = this@Basis.Global.Base(options);

      this.maximalLevel = min(32, options.maximalLevel);
      this.level = 0;

      this.Yij = cell(1, this.maximalLevel);
      this.Li = zeros(1, this.maximalLevel);
      this.Mi = zeros(1, this.maximalLevel, 'uint32');
      this.Ni = zeros(1, this.maximalLevel, 'uint32');
    end

    function ensureLevel(this, level)
      assert(level <= this.maximalLevel);

      levels = (this.level + 1):level;
      if isempty(levels), return; end

      for i = levels
        [ this.Yij{i}, this.Li(i), this.Mi(i) ] = ...
          this.computeBasisNodes(i);
        this.Ni(i) = numel(this.Yij{i});
      end

      this.level = level;
    end
  end
end
