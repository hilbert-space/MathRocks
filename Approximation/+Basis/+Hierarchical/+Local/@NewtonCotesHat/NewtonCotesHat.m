classdef NewtonCotesHat < Basis.Hierarchical.Local.Base
  methods
    function this = NewtonCotesHat(varargin)
      this = this@Basis.Hierarchical.Local.Base(varargin{:});

      if this.maximalLevel > 255
        warning('The maximal level is too high; changing to 255.');
        this.maximalLevel = 255;
      end
    end
  end
end
