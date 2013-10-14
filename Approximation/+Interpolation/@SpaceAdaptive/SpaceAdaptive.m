classdef SpaceAdaptive < Interpolation.SparseGrid
  methods
    function this = SpaceAdaptive(varargin)
      this = this@Interpolation.SparseGrid(varargin{:});
    end

    function values = evaluate(this, output, nodes, varargin)
      values = this.basis.evaluate(output.levels, output.orders, ...
        nodes, output.surpluses);
    end

    function values = sample(this, output, sampleCount)
      values = this.evaluate(output, ...
        rand(sampleCount, output.inputCount));
    end
  end
end
