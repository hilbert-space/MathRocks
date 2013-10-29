classdef NewtonCotesHat < Basis.Hierarchical.Local.Base
  methods
    function this = NewtonCotesHat(varargin)
      this = this@Basis.Hierarchical.Local.Base(varargin{:});

      if this.maximalLevel > 32
        warning('The maximal level is too high. Changing it to 32.');
        this.maximalLevel = 32;
      end
    end
  end
end
