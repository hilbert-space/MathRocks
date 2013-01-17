classdef Options < dynamicprops
  methods
    function this = Options(varargin)
      this.update(varargin{:});
    end

    function value = get(this, name, default)
      if isprop(this, name)
        value = this.(name);
      else
        value = default;
      end
    end

    function set(this, name, value)
      if ~isprop(this, name), this.addprop(name); end
      if isa(this.(name), 'Options')
        this.(name).update(value);
      else
        this.(name) = value;
      end
    end

    function value = getSet(this, name, default)
      if isprop(this, name)
        value = this.(name);
      else
        this.addprop(name);
        if isa(default, 'function_handle')
          value = default();
        else
          value = default;
        end
        this.(name) = value;
      end
    end

    function update(this, varargin)
      i = 1;

      while i <= length(varargin)
        item = varargin{i};

        if isempty(item)
          i = i + 1;
          continue;
        end

        if isa(item, 'Options')
          names = properties(item);
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
  end

  methods (Static)
    [ data, options ] = extract(varargin)
  end
end
