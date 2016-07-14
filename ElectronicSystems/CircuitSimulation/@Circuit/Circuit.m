classdef Circuit < handle
  properties (SetAccess = 'protected')
    name
    filename

    targetName = 'Ileak'
    targetFilename

    parameterNames
    parameterCount
    parameterRanges
    parameterFilename

    dataFilename
  end

  methods
    function this = Circuit(varargin)
      options = Options(varargin{:});

      this.name = options.name;
      this.parameterNames = fieldnames(options.parameters);
      this.parameterCount = length(this.parameterNames);
      this.parameterRanges = cell(1, this.parameterCount);

      for i = 1:this.parameterCount
        name = this.parameterNames{i};
        this.parameterRanges{i} = options.parameters.(name).range;
      end

      prefix = File.join(File.trace, '..', 'Assets', ...
        String.join('_', this.name, this.parameterNames));

      this.filename = [prefix, '.sp'];
      this.dataFilename = [prefix, '.data'];
      this.targetFilename = [prefix, '.sw0'];
      this.parameterFilename = [prefix, '.param'];
    end

    function display(this)
      display(Options(this), class(this));
    end

    function string = toString(this)
      string = String(Options(this));
    end
  end
end
