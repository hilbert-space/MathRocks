classdef ProcessVariation < handle
  properties (SetAccess = 'private')
    transformations
    parameterCount
    dimensionCount
  end

  properties (Access = 'private')
    merging
  end

  methods
    function this = ProcessVariation(varargin)
      options = Options(varargin{:});

      parameters = options.parameters;
      this.parameterCount = length(parameters);

      this.transformations = cell(1, this.parameterCount);
      this.merging = false(1, this.parameterCount);

      this.dimensionCount = 0;
      for i = 1:this.parameterCount
        parameter = parameters.get(i);

        [ correlation, contribution, this.merging(i) ] = ...
          this.correlate(parameter, options);
        this.transformations{i} = this.transform( ...
          parameter, correlation, contribution, options);

        this.dimensionCount = this.dimensionCount + ...
          this.transformations{i}.dimensionCount;
      end
    end

    function varargout = evaluate(this, varargin)
      varargout = cell(1, this.parameterCount);
      for i = 1:this.parameterCount
        data = this.transformations{i}.evaluate(varargin{i});
        if this.merging(i)
          data = bsxfun(@plus, data(:, end), data(:, 1:(end - 1)));
        end
        varargout{i} = data;
      end
    end

    function varargout = sample(this, sampleCount)
      varargout = cell(1, this.parameterCount);
      for i = 1:this.parameterCount
        data = this.transformations{i}.sample(sampleCount);
        if this.merging(i)
          data = bsxfun(@plus, data(:, end), data(:, 1:(end - 1)));
        end
        varargout{i} = data;
      end
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        Utils.toString(struct( ...
          'transformations', this.transformations, ...
          'parameterCount', this.parameterCount, ...
          'dimensionCount', this.dimensionCount)));
    end
  end

  methods (Access = 'protected')
    transformation = transform(this, parameter, correlation, contribution, options)
    [ correlation, contribution, merging ] = correlate(this, parameter, options)
  end
end
