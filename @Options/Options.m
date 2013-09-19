classdef Options < handle
  properties (SetAccess = 'protected')
    names
    values
  end

  methods
    function this = Options(varargin)
      this.names = {};
      this.values = containers.Map('keyType', 'char', 'valueType', 'any');
      this.update(varargin{:});
    end

    function this = add(this, name, value)
      this.names{end + 1} = name;
      this.values(name) = value;
    end

    function this = remove(this, name)
      this.values(name) = [];
      for i = 1:length(this.names)
        if strcmp(this.names{i}, name)
          this.names(i) = [];
          return;
        end
      end
    end

    function value = get(this, name, value)
      if this.values.isKey(name)
        value = this.values(name);
      end
    end

    function this = set(this, name, value)
      if this.values.isKey(name)
        if isa(this.values(name), 'Options') && isa(value, 'struct')
          this.values(name).update(value);
        else
          this.values(name) = value;
        end
      else
        this.add(name, value);
      end
    end

    function value = fetch(this, name, value)
      if this.values.isKey(name)
        value = this.values(name);
        this.remove(name);
      end
    end

    function value = ensure(this, name, value)
      if this.values.isKey(name)
        value = this.values(name);
      else
        this.add(name, value);
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
          %
          % NOTE: Need a separate treatment of Options here
          % since this code can be called from the constructor,
          % and subsref and subsasgn do not work from there.
          %
          names = fieldnames(item);
          for j = 1:length(names)
            this.set(names{j}, item.get(names{j}));
          end
          i = i + 1;
        elseif isa(item, 'struct')
          names = fieldnames(item);
          for j = 1:length(names)
            this.set(names{j}, item.(names{j}));
          end
          i = i + 1;
        else
          this.set(item, varargin{i + 1});
          i = i + 2;
        end
      end
    end

    function result = has(this, name)
      result = this.values.isKey(name);
    end

    function result = length(this)
      result = length(this.names);
    end

    function varargout = subsref(this, s)
      name = s(1).subs;
      if isprop(this, name) || ismethod(this, name)
        if nargout > 0
          varargout = cell(1, nargout);
          [ varargout{:} ] = builtin('subsref', this, s);
        else
          builtin('subsref', this, s);
        end
      else
        if isnumeric(name)
          s(1).subs = this.names{name};
        end
        s(1).type = '()';
        if nargout > 0
          varargout = cell(1, nargout);
          [ varargout{:} ] = subsref(this.values, s);
        else
          subsref(this.values, s);
        end
      end
    end

    function this = subsasgn(this, s, value)
      name = s(1).subs;
      if isprop(this, name) || ismethod(this, name)
        builtin('subsasgn', this, s, value);
      elseif length(s) > 1
        if isnumeric(name)
          s(1).subs = this.names{name};
        end
        s(1).type = '()';
        subsasgn(this.values, s, value);
      else
        if isnumeric(name), name = this.names{name}; end
        this.set(name, value);
      end
    end

    %
    % Compatibility with the built-in type struct.
    %

    function result = isfield(this, name)
      result = this.values.isKey(name);
    end

    function result = fieldnames(this)
      result = this.names;
    end

    function result = isa(this, class)
      if strcmp(class, 'struct')
        result = true;
      else
        result = builtin('isa', this, class);
      end
    end
  end

  methods (Static)
    [ data, options ] = extract(varargin)
  end
end
