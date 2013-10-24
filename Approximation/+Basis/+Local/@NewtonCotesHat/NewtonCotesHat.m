classdef NewtonCotesHat < ...
  Basis.Base.NewtonCotesHat & ...
  Basis.Local.Base

  methods
    function this = NewtonCotesHat(varargin)
      options = Options(varargin{:});

      this = this@Basis.Base.NewtonCotesHat(options);
      this = this@Basis.Local.Base(options);
    end
  end
end
