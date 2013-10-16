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

      this.Yij = cell(this.maximalLevel, 1);
      this.Li = zeros(this.maximalLevel, 1);
      this.Mi = zeros(this.maximalLevel, 1, 'uint32');
      this.Ni = zeros(this.maximalLevel, 1, 'uint32');

      for i = 1:this.maximalLevel
        [ this.Yij{i}, this.Li(i), this.Mi(i) ] = ...
          this.computeBasisNodes(i);
        this.Ni(i) = numel(this.Yij{i});
      end
    end
  end
end
