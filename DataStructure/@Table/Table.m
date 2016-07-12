classdef Table < handle
  properties (SetAccess = 'protected')
    parameterNames
    parameterCount
    parameterData
  end

  properties (Access = 'protected')
    mapping
  end

  methods
    function this = Table(varargin)
      options = Options(varargin{:});

      file = fopen(options.filename, 'r');
      line = fgetl(file);
      fclose(file);

      assert(ischar(line));
      assert(~isempty(line));

      this.parameterNames = regexp(line, '\t', 'split');

      this.parameterCount = length(this.parameterNames);
      assert(this.parameterCount > 0);

      this.parameterData = cell(1, this.parameterCount);
      this.mapping = containers.Map('keyType', 'char', 'valueType', 'uint8');

      %
      % Fill in the mapping.
      %
      for i = 1:this.parameterCount
        assert(isnan(str2double(this.parameterNames{i})));
        this.mapping(this.parameterNames{i}) = i;
      end

      %
      % Read the data.
      %
      data = dlmread(options.filename, '\t', 1, 0);
      for i = 1:this.parameterCount
        this.parameterData{i} = data(:, i);
      end

      %
      % Ensure that there are not values outside of the desired ranges.
      %
      if options.has('rangeConstraints')
        this.constrainRange(options.rangeConstraints);
      end
    end
  end

  methods (Access = 'protected')
    function remove(this, parameter)
      j = this.mapping(parameter);

      for i = (j + 1):this.parameterCount
        this.mapping(this.parameterNames{i}) = i - 1;
      end

      this.mapping.remove(parameter);
      this.parameterNames(j) = [];
      this.parameterData(j) = [];
      this.parameterCount = this.parameterCount - 1;
    end
  end

  methods (Access = 'private')
    function constrainRange(this, parameters)
      I = [];

      names = fieldnames(parameters);
      for i = 1:length(names)
        j = this.mapping(names{i});
        mn = min(parameters.(names{i}));
        mx = max(parameters.(names{i}));
        I = [I; ...
          find(this.parameterData{j} < mn); ...
          find(this.parameterData{j} > mx)];
      end

      I = unique(I);

      for i = 1:this.parameterCount
        data = this.parameterData{i};
        data(I) = [];
        this.parameterData{i} = data;
      end
    end
  end
end
