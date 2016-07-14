classdef Base < Temperature.Base
  properties (Access = 'protected')
    At
    Bt
  end

  methods
    function this = Base(varargin)
      this = this@Temperature.Base(varargin{:});

      nodeCount = this.nodeCount;
      processorCount = this.processorCount;

      M = [diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount)];

      Cm1 = diag(1 ./ this.capacitance);

      this.At = - Cm1 * this.conductance;
      this.Bt = Cm1 * M;
    end
  end
end
