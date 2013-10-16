classdef DimensionWise < Basis.Hat.Base
  properties (SetAccess = 'private')
    maximalLevel

    Yij
    Li
    Mi
    Ni
  end

  methods
    function this = DimensionWise(varargin)
      options = Options(varargin{:});
      this = this@Basis.Hat.Base(options);

      this.maximalLevel = options.maximalLevel;

      assert(this.maximalLevel <= 32);

      this.Yij = cell(1, this.maximalLevel);
      this.Li = zeros(1, this.maximalLevel);
      this.Mi = zeros(1, this.maximalLevel, 'uint32');
      this.Ni = zeros(1, this.maximalLevel, 'uint32');

      for i = 1:this.maximalLevel
        [ this.Yij{i}, this.Li(i), this.Mi(i) ] = ...
          this.computeBasisNodes(i);
        this.Ni(i) = numel(this.Yij{i});
      end
    end
  end
end
