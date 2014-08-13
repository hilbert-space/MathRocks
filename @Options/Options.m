classdef Options < handle
  properties (Access = 'private')
    values__
    names__
  end

  methods
    function this = Options(varargin)
      this.values__ = containers.Map( ...
        'KeyType', 'char', 'ValueType', 'any');
      this.names__ = {};
      this.update(varargin{:});
    end

    function this = add(this, name, value)
      assert(~this.values__.isKey(name));
      this.values__(name) = value;
      this.names__ = [this.names__, { name }];
    end

    function this = remove(this, name)
      for i = 1:length(this.names__)
        if ~strcmpi(this.names__{i}, name), continue; end
        remove(this.values__, name);
        this.names__(i) = [];
        return;
      end
      assert(false);
    end

    function value = get(this, name, value)
      if isnumeric(name), name = this.names__{name}; end
      if isKey(this.values__, name)
        value = this.values__(name);
      end
    end

    function this = set(this, name, value)
      if iscell(name)
        %
        % Multiple assignments
        %
        if iscell(value)
          %
          % Each property has a separate value
          %
          for i = 1:length(name)
            set(this, name{i}, value{i});
          end
        else
          %
          % All properties have the same value
          %
          for i = 1:length(name)
            set(this, name{i}, value);
          end
        end
      else
        %
        % Singular assignemnt
        %
        if isnumeric(name), name = this.names__{name}; end
        if isKey(this.values__, name)
          oldValue = this.values__(name);
          if isa(oldValue, 'Options') && isstruct(value)
            oldValue.update(value);
            this.values__(name) = oldValue;
          else
            this.values__(name) = value;
          end
        else
          add(this, name, value);
        end
      end
    end

    function value = fetch(this, name, value)
      if isKey(this.values__, name)
        value = this.values__(name);
        remove(this, name);
      end
    end

    function value = ensure(this, name, value)
      if isKey(this.values__, name)
        value = this.values__(name);
      else
        add(this, name, value);
      end
    end

    function options = subset(this, names)
      options = Options;
      for i = 1:length(names)
        add(options, names{i}, get(this, names{i}));
      end
    end

    function this = update(this, varargin)
      i = 1;

      while i <= length(varargin)
        item = varargin{i};

        if isempty(item)
          i = i + 1;
          continue;
        end

        if isa(item, 'Options')
          names = item.names__;
          for j = 1:length(names)
            set(this, names{j}, item.values__(names{j}));
          end
          i = i + 1;
        elseif isstruct(item)
          names = fieldnames(item);
          for j = 1:length(names)
            if numel(item) == 1
              set(this, names{j}, item.(names{j}));
            else
              value = cell(1, numel(item));
              [value{:}] = item.(names{j});
              set(this, names{j}, value);
            end
          end
          i = i + 1;
        elseif isobject(item)
          names = properties(item);
          for j = 1:length(names)
            set(this, names{j}, item.(names{j}));
          end
          i = i + 1;
        else
          set(this, item, varargin{i + 1});
          i = i + 2;
        end
      end
    end

    function options = clone(this)
      options = Options;
      for i = 1:length(this.names__)
        name = this.names__{i};
        value = this.values__(name);
        if isa(value, 'Options')
          value = value.clone;
        end
        set(options, name, value);
      end
    end

    function result = has(this, name)
      result = isKey(this.values__, name);
    end

    function result = length(this)
      result = length(this.names__);
    end

    function this = subsasgn(this, s, value)
      name = s(1).subs;
      if isKey(this.values__, name)
        if numel(s) == 1
          this.values__(name) = value;
        else
          result = this.values__(name);
          subsasgn(result, s(2:end), value);
        end
      else
        set(this, name, value);
      end
    end

    function result = subsref(this, s)
      if s(1).type == '.' && ismethod(this, s(1).subs)
        result = builtin('subsref', this, s);
        return;
      end
      result = this.values__(s(1).subs);
      if numel(s) == 1, return; end
      result = subsref(result, s(2:end));
    end

    %
    % Compatibility with the built-in type struct.
    %

    function result = isfield(this, name)
      result = isKey(this.values__, name);
    end

    function result = fieldnames(this)
      result = this.names__;
    end

    function result = isstruct(~)
      result = true;
    end

    function result = isa(this, class)
      if strcmpi(class, 'struct')
        result = true;
      else
        result = builtin('isa', this, class);
      end
    end
  end
end
