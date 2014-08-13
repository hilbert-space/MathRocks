classdef Questionnaire < handle
  properties (SetAccess = 'private')
    databaseFilename
    dataMap
    optionMap

    skip
  end

  methods
    function this = Questionnaire(databaseFilename)
      if nargin == 0
        [~, ~, functionName] = File.trace(2);
        databaseFilename = String.join('_', functionName, 'input.mat');
      end

      this.databaseFilename = databaseFilename;
      this.dataMap = containers.Map;
      this.optionMap = containers.Map;

      this.load();
    end

    function append(this, name, varargin)
      options = Options(varargin{:});
      if ~this.dataMap.isKey(name)
        this.dataMap(name) = options.get('default', []);
      end
      this.optionMap(name) = options;
    end

    function value = request(this, name, varargin)
      if this.optionMap.isKey(name)
        options = Options(this.optionMap(name), varargin{:});
      else
        options = Options(varargin{:});
      end
      if this.dataMap.isKey(name) && ~isempty(this.dataMap(name))
        value = this.dataMap(name);
      else
        value = options.get('default', []);
      end
      if ~isempty(value)
        if options.has('format')
          prompt = sprintf('Enter %s [%s]: ', options.description, ...
            String(value, options.format));
        else
          prompt = sprintf('Enter %s [%s]: ', options.description, ...
            String(value));
        end
      else
        prompt = sprintf('Enter %s: ', options.description);
      end
      if this.skip
        fprintf('%s\n', prompt);
      else
        value = Terminal.request( ...
          'prompt', prompt, options, 'default', value);
      end
      this.dataMap(name) = value;
    end

    function autoreply(this, enabled)
      if nargin < 2, enabled = true; end
      this.skip = enabled;
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
end
