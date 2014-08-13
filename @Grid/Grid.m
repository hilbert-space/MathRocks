classdef Grid < Table
  properties (SetAccess = 'protected')
    targetName
    targetData
    parameterSweeps
  end

  methods
    function this = Grid(varargin)
      options = Options(varargin{:});

      this = this@Table(options);

      this.targetName = options.targetName;
      this.targetData = ...
        this.parameterData{this.mapping(this.targetName)};
      this.remove(this.targetName);

      %
      % Find the unique values taken by the data
      % and reshape the data.
      %
      this.parameterSweeps = cell(1, this.parameterCount);
      dimensions = zeros(1, this.parameterCount);

      for i = 1:this.parameterCount
        this.parameterSweeps{i} = sort(unique(this.parameterData{i}));
        dimensions(i) = length(this.parameterSweeps{i});
      end

      this.targetData = reshape(this.targetData, dimensions);
      for i = 1:this.parameterCount
        this.parameterData{i} = ...
          reshape(this.parameterData{i}, dimensions);
      end

      %
      % Ensure that the maximal number of points is not violated.
      %
      if options.has('countConstraints')
        this.constrainCount(options.countConstraints);
      end
    end
  end

  methods (Access = 'private')
    function constrainCount(this, parameters)
      I = cell(1, this.parameterCount);

      names = fieldnames(parameters);
      for i = 1:this.parameterCount
        I{i} = 1:length(this.parameterSweeps{i});
        for j = 1:length(names)
          if i ~= this.mapping(names{j}), continue; end
          count = length(I{i});
          if parameters.(names{j}) >= count, break; end
          divide = round(count / parameters.(names{j}));
          I{i} = 1:divide:count;
          break;
        end
      end

      this.targetData = this.targetData(I{:});
      for i = 1:this.parameterCount
        this.parameterSweeps{i} = this.parameterSweeps{i}(I{i});
        this.parameterData{i} = this.parameterData{i}(I{:});
      end
    end
  end
end
