classdef Fitting < handle
  properties (SetAccess = 'private')
    parameterNames
    parameterCount
    parameterSweeps
  end

  properties (Access = 'private')
    output
  end

  methods
    function this = Fitting(varargin)
      options = Options(varargin{:});
      grid = Grid(options);
      this.parameterNames = grid.parameterNames;
      this.parameterCount = grid.parameterCount;
      this.parameterSweeps = grid.parameterSweeps;
      this.output = this.construct( ...
        grid.targetData, grid.parameterData, options);
    end

    function target = compute(this, varargin)
      if nargin == 1 && (isa(varargin{1}, 'struct') || ...
        isa(varargin{1}, 'Options'))

        %
        % The parameters are packed into one structured object.
        %
        parameters = cell(1, this.parameterCount);
        for i = 1:this.parameterCount
          parameters{i} = varargin{1}.(this.parameterNames{i});
        end
        target = this.evaluate(this.output, parameters{:});
      else
        %
        % The parameters are given one by one.
        %
        target = this.evaluate(this.output, varargin{:});
      end
    end
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, targetData, parameterData, options)
    target = evaluate(this, output, varargin)
  end
end
