classdef ChebyshevGaussLobattoLagrange < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    Yij
    Yi
    Wi
    Ji
    Mi
    Ni
  end

  methods
    function this = ChebyshevGaussLobattoLagrange(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Global.Base(options);

      maximalLevel = min(10, options.maximalLevel);

      Yij = cell(1, maximalLevel);
      Yi = cell(1, maximalLevel);
      Wi = cell(1, maximalLevel);
      Ji = cell(1, maximalLevel);
      Mi = zeros(1, maximalLevel, 'uint32');
      Ni = zeros(1, maximalLevel, 'uint32');

      for i = 1:maximalLevel
        switch i
        case 1
          Yij{i} = 0.5;
          Yi{i} = 0.5;
          Wi{i} = 0.5;
          Ji{i} = uint32(1);
          Mi(i) = uint32(1);
        case 2
          Yij{i} = [ 0 1 ];
          Yi{i} = [ 0 0.5 1 ];
          Wi{i} = [ 0.5 -1 0.5 ];
          Ji{i} = uint32([ 1 3 ]);
          Mi(i) = uint32(3);
        otherwise
          Ji{i} = uint32((1:2^(i - 2)) * 2);
          Mi(i) = uint32(2^(i - 1) + 1);
          Yij{i} = (-cos(pi * (double(Ji{i}) - 1) / (double(Mi(i)) - 1)) + 1) / 2;
          Yi{i} = (-cos(pi * (double(1:Mi(i)) - 1) / (double(Mi(i)) - 1)) + 1) / 2;
          Wi{i} = (-1).^(double(1:Mi(i)) - 1);
          Wi{i}(1) = 0.5;
          Wi{i}(end) = 0.5 * (-1)^(double(Mi(i)) - 1);
        end
        Ni(i) = numel(Yij{i});
      end

      this.Yij = Yij;
      this.Yi = Yi;
      this.Wi = Wi;
      this.Ji = Ji;
      this.Mi = Mi;
      this.Ni = Ni;
    end
  end
end
