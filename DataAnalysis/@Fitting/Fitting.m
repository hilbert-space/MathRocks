classdef Fitting < handle
  properties (SetAccess = 'private')
    dimensionCount
    names
    sweeps
    output
  end

  methods
    function this = Fitting(varargin)
      options = Options(varargin{:});
      grid = Grid(options);
      this.dimensionCount = grid.dimensionCount;
      this.names = grid.names;
      this.sweeps = grid.sweeps;
      this.output = this.construct( ...
        grid.target, grid.parameters, options);
    end

    function target = compute(this, some)
      if isa(some, 'cell')
        target = this.evaluate(this.output, some);
      else
        parameters = cell(1, this.dimensionCount);
        for i = 1:this.dimensionCount
          parameters{i} = some.(this.names{i});
        end
        target = this.evaluate(this.output, parameters);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, target, parameters, options)
    target = evaluate(this, output, parameters)
  end
end
