classdef NewtonCotesHat < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    Yij
    Li
    Mi
    Ni
  end

  methods
    function this = NewtonCotesHat(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Global.Base(options);

      if this.maximalLevel > 32
        warning('The maximal level is too high; changing to 32.');
        this.maximalLevel = 32;
      end

      Yij = cell(1, this.maximalLevel);
      Li = zeros(1, this.maximalLevel);
      Mi = zeros(1, this.maximalLevel, 'uint32');
      Ni = zeros(1, this.maximalLevel, 'uint32');

      for i = 1:this.maximalLevel
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
