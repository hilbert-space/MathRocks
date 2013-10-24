classdef NewtonCotesHat < Basis.Base.Base
  methods
    function this = NewtonCotesHat(varargin)
      this = this@Basis.Base.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ Yij, Li, Mi ] = computeBasisNodes(this, i)
    result = computeBasisCrossExpectation(this, I1, J1, I2, J2)
    result = computeBasisExpectation(this, I)
    result = computeBasisSecondRawMoment(this, I)
  end
end
