classdef Table < dynamicprops
  properties (SetAccess = 'protected')
    names
    parameters

    dimensionCount
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

      this.names = regexp(line, '\t', 'split');

      this.dimensionCount = length(this.names);
      assert(this.dimensionCount > 0);

      this.parameters = cell(1, this.dimensionCount);
      this.mapping = containers.Map('KeyType', 'char', 'ValueType', 'uint8');

      %
      % Fill in the mapping.
      %
      for i = 1:this.dimensionCount
        assert(isnan(str2double(this.names{i})));
        this.mapping(this.names{i}) = i;
      end

      %
      % Read the data.
      %
      data = dlmread(options.filename, '\t', 1, 0);
      for i = 1:this.dimensionCount
        this.parameters{i} = data(:, i);
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
    function remove(this, name)
      j = this.mapping(name);

      for i = (j + 1):this.dimensionCount
        this.mapping(this.names{i}) = i - 1;
      end

      this.mapping.remove(name);
      this.names(j) = [];
      this.parameters(j) = [];
      this.dimensionCount = this.dimensionCount - 1;
    end
  end

  methods (Access = 'private')
    function constrainRange(this, constraints)
      I = [];

      for i = 1:length(constraints)
        name = constraints(i).name;
        j = this.mapping(name);
        mn = min(constraints(i).range);
        mx = max(constraints(i).range);
        I = [ I; ...
          find(this.parameters{j} < mn); ...
          find(this.parameters{j} > mx) ];
      end

      I = unique(I);

      for i = 1:this.dimensionCount
        data = this.parameters{i};
        data(I) = [];
        this.parameters{i} = data;
      end
    end
  end
end
