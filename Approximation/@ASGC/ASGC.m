classdef ASGC < handle
  properties (SetAccess = 'private')
    interpolant
    output
  end

  properties
    nodeCount
    expectation
  end

  methods
    function this = ASGC(f, varargin)
      options = Options(varargin{:});
      this.interpolant = Interpolation(options);
      this.output = this.interpolant.construct(f);
      this.nodeCount = this.output.nodeCount;
      this.expectation = this.interpolant.integrate(this.output);
    end

    function values = evaluate(this, nodes)
      values = this.interpolant.evaluate(this.output, nodes);
    end
  end
end
