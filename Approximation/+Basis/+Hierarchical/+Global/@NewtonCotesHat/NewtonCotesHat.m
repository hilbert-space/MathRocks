classdef NewtonCotesHat < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    Yij
    Li
    Mi
    Ni
  end

  methods
    function this = Global(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Global.Base(options);

      maximalLevel = min(32, options.maximalLevel);

      Yij = cell(1, maximalLevel);
      Li = zeros(1, maximalLevel);
      Mi = zeros(1, maximalLevel, 'uint32');
      Ni = zeros(1, maximalLevel, 'uint32');

      for i = 1:maximalLevel
        switch i
        case 1
          Yij{i} = 0.5;
          Mi(i) = uint32(1);
          Li(i) = 1;
        case 2
          Yij{i} = [ 0 1 ];
          Mi(i) = uint32(3);
          Li(i) = 0.5;
        otherwise
          Yij{i} = (2 * (1:2^(i - 2)) - 1) * 2^(-i + 1);
          Mi(i) = uint32(2^(i - 1) + 1);
          Li(i) = 1 / (double(Mi(i)) - 1);
        end
        Ni(i) = numel(Yij{i});
      end

      this.Yij = Yij;
      this.Li = Li;
      this.Mi = Mi;
      this.Ni = Ni;
    end
  end
end
