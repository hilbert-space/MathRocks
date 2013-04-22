classdef Numeric < HotSpot.Base
  properties (Access = 'private')
    At
    Bt
  end

  methods
    function this = Numeric(varargin)
      this = this@HotSpot.Base(varargin{:});

      nodeCount = this.nodeCount;
      processorCount = this.processorCount;

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      Cm1 = diag(1 ./ this.capacitance);

      this.At = - Cm1 * this.conductance;
      this.Bt = Cm1 * M;
    end

    function varargout = compute(this, Pdyn, varargin)
      options = Options(varargin{:});
      varargout = cell(1, nargout);
      [ varargout{:} ] = this.([ 'compute', options.method ])(Pdyn, options);
    end
  end
end
