classdef Options < dynamicprops
  methods
    function this = Options(varargin)
      this.update(varargin{:});
    end

    function this = add(this, name, value)
      addprop(this, name);
      this.(name) = value;
    end

    function this = remove(this, name)
      delete(findprop(this, name));
    end

    function value = get(this, name, value)
      if isprop(this, name)
        value = this.(name);
      end
    end

    function this = set(this, name, value)
      if isprop(this, name)
        if isa(this.(name), 'Options') && isa(value, 'struct')
          this.(name).update(value);
        else
          this.(name) = value;
        end
      else
        this.add(name, value);
      end
    end

    function value = fetch(this, name, value)
      if isprop(this, name)
        value = this.(name);
        delete(findprop(this, name));
      end
    end

    function value = ensure(this, name, value)
      if isprop(this, name)
        value = this.(name);
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

        if isa(item, 'struct')
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
      result = isprop(this, name);
    end

    function result = length(this)
      result = length(properties(this));
    end

    function this = subsasgn(this, s, value)
      name = s(1).subs;
      if isprop(this, name)
        [ ~ ] = builtin('subsasgn', this, s, value);
      else
        this.set(name, value);
      end
    end

    %
    % Compatibility with the built-in type struct.
    %

    function result = isfield(this, name)
      result = isprop(this, name);
    end

    function result = fieldnames(this)
      result = properties(this);
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
