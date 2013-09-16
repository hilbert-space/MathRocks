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
      if length(varargin) == 1
        if isa(varargin{1}, 'cell')
          %
          % The parameters are packed into a cell array.
          %
          target = this.evaluate(this.output, varargin{1}{:});
        elseif (isa(varargin{1}, 'struct') || isa(varargin{1}, 'Options'))
          %
          % The parameters are packed into a structured object.
          %
          parameters = cell(1, this.parameterCount);
          for i = 1:this.parameterCount
            parameters{i} = varargin{1}.(this.parameterNames{i});
          end
          target = this.evaluate(this.output, parameters{:});
        end
      else
        %
        % The parameters are given one by one.
        %
        target = this.evaluate(this.output, varargin{:});
      end
    end

    function [ parameters, dimensions ] = assign(this, varargin)
      options = Options(varargin{:});

      reference = options.reference;
      parameters = options.get('parameters', []);
      dimensions = options.get('dimensions', 1);

      %
      % Unify the input parameters.
      %
      if isa(parameters, 'cell')
        newParameters = struct;
        for i = 1:this.parameterCount
          name = this.parameterNames{i};
          newParameters.(name) = parameters{i};
        end
        parameters = newParameters;
      end

      %
      % Fill in gaps with reference scalars.
      %
      for i = 1:this.parameterCount
        name = this.parameterNames{i};
        if isfield(parameters, name) && ...
          ~isempty(parameters.(name)), continue; end
        parameters.(name) = reference.(name);
      end

      %
      % Detect the desired dimensionality.
      %
      for i = 1:length(dimensions)
        if ~isnan(dimensions(i)), continue; end
        for j = 1:this.parameterCount
          name = this.parameterNames{i};
          if ndims(parameters.(name)) < i, continue; end
          dimensions(i) = size(parameters.(name), i);
          break;
        end
      end
      dimensions(isnan(dimensions)) = 1;

      %
      % Enforce the desired dimensionality except for those
      % elements that are equal to NaN.
      %
      for i = 1:this.parameterCount
        name = this.parameterNames{i};
        if isnan(parameters.(name)), continue; end
        dims = size(parameters.(name));
        pattern = dimensions;
        pattern(1:length(dims)) = pattern(1:length(dims)) ./ dims;
        if all(pattern == 1), continue; end
        parameters.(name) = repmat(parameters.(name), pattern);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, targetData, parameterData, options)
    target = evaluate(this, output, varargin)
  end
end
