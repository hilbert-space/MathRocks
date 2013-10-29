classdef ChebyshevLagrange < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    nodes
    counts
  end

  methods
    function this = ChebyshevLagrange(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Global.Base(options);

      if this.maximalLevel > 10
        warning('The maximal level is too high; changing to 10.');
        this.maximalLevel = 10;
      end

      this.nodes = cell(1, this.maximalLevel);
      this.counts = zeros(1, this.maximalLevel, 'uint32');

      for i = 1:this.maximalLevel
        switch i
        case 1
          this.nodes{i} = 0.5;
        case 2
          this.nodes{i} = [ 0 1 ];
        otherwise
          this.nodes{i} = (-cos(pi * ((1:2^(i - 2)) * 2 - 1) / 2^(i - 1)) + 1) / 2;
        end
        this.counts(i) = numel(this.nodes{i});
      end
    end
  end
end
