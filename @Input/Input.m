classdef Input < handle
  properties (SetAccess = 'private')
    databaseFilename
    dataMap
    optionMap
  end

  methods
    function this = Input(databaseFilename)
      if nargin == 0
        [ ~, ~, functionName ] = File.trace(2);
        databaseFilename = sprintf('%s_input.mat', functionName);
      end

      this.databaseFilename = databaseFilename;
      this.dataMap = Map('char');
      this.optionMap = Map('char');
    end

    function append(this, name, varargin)
      options = Options(varargin{:});
      this.dataMap(name) = options.get('default', []);
      this.optionMap(name) = options;
    end

    function value = read(this, name, varargin)
      if this.optionMap.isKey(name)
        options = Options(this.optionMap(name), varargin{:});
      else
        options = Options(varargin{:});
      end
      if this.dataMap.isKey(name)
        value = this.dataMap(name);
      else
        value = options.get('default', [])
      end
      if ~isempty(value)
        if options.has('format')
          prompt = sprintf([ 'Enter %s [', options.format ']: ' ], ...
            options.description, value);
        else
          prompt = sprintf('Enter %s [%s]: ', options.description, ...
            Utils.toString(value));
        end
      else
        prompt = sprintf('Enter %s: ', options.description);
      end
      value = Input.request('prompt', prompt, options, 'default', value);
      this.dataMap(name) = value;
    end

    function load(this)
      if File.exist(this.databaseFilename)
        load(this.databaseFilename);
        this.dataMap = dataMap;
      end
    end

    function save(this)
      dataMap = this.dataMap;
      save(this.databaseFilename, 'dataMap', '-v7.3');
    end
  end

  methods (Static)
    output = request(varargin)
  end
end
