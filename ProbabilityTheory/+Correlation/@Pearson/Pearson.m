classdef Pearson < Correlation.Base
  methods
    function this = Pearson(varargin)
      this = this@Correlation.Base(varargin{:});
    end
  end

  methods (Static)
    function correlation = random(dimension)
      S = randn(dimension);
      S = S' * S;
      correlation = Correlation.Pearson(corrcov(S));
    end

    function correlation = compute(data)
      correlation = Correlation.Pearson(corr(data, 'type', 'Pearson'));
    end
  end
end
