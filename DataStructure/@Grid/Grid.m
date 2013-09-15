classdef Grid < Table
  properties (SetAccess = 'protected')
    target
    sweeps
  end

  methods
    function this = Grid(varargin)
      options = Options(varargin{:});

      this = this@Table(options);

      this.target = this.parameters{this.mapping(options.target)};
      this.remove(options.target);

      %
      % Find the unique values taken by the parameters
      % and reshape the data.
      %
      sweeps = cell(1, this.dimensionCount);
      dimensions = zeros(1, this.dimensionCount);

      for i = 1:this.dimensionCount
        sweeps{i} = sort(unique(this.parameters{i}));
        dimensions(i) = length(sweeps{i});
      end

      this.sweeps = sweeps;

      this.target = reshape(this.target, dimensions);
      for i = 1:this.dimensionCount
        this.parameters{i} = reshape(this.parameters{i}, dimensions);
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
    function constrainCount(this, constraints)
      I = cell(1, this.dimensionCount);

      for i = 1:this.dimensionCount
        I{i} = 1:length(this.sweeps{i});
        for j = 1:length(constraints)
          if i ~= this.mapping(constraints(j).name), continue; end
          count = length(I{i});
          if constraints(j).count >= count, break; end
          divide = round(count / constraints(j).count);
          I{i} = 1:divide:count;
          break;
        end
      end

      this.target = this.target(I{:});
      for i = 1:this.dimensionCount
        this.sweeps{i} = this.sweeps{i}(I{i});
        this.parameters{i} = this.parameters{i}(I{:});
      end
    end
  end
end
