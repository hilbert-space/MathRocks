classdef SpaceAdaptive < Interpolation.SparseGrid
  properties (SetAccess = 'private')
    basis
  end

  methods
    function this = SpaceAdaptive(varargin)
      this = this@Interpolation.SparseGrid(varargin{:});

      this.basis = Basis.Hat.SpaceWise;
    end

    function values = evaluate(this, output, nodes, varargin)
      values = this.basis.evaluate(nodes, output.levels, output.orders, ...
        output.surpluses);
    end

    function values = sample(this, output, sampleCount)
      values = this.evaluate(output, ...
        rand(sampleCount, output.inputCount));
    end
  end
end
