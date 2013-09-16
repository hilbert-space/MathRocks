classdef Options < dynamicprops
  methods
    function this = Options(varargin)
      this.update(varargin{:});
    end

    function value = get(this, name, default)
      if isprop(this, name)
        value = this.(name);
      elseif nargin > 2
        value = default;
      else
        error('The field %s does not exist.', name);
      end
    end

    function set(this, name, value)
      if ~isprop(this, name), this.addprop(name); end
      if isa(this.(name), 'Options') && ...
         (isa(value, 'Options') || isa(value, 'struct'))

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
      result = isprop(this, name);
    end

    function result = isfield(this, name)
      %
      % To make it behave like a struct.
      %
      result = isprop(this, name);
    end

    function this = subsasgn(this, s, v)
      if strcmp(s(1).type, '.')
        if length(s) == 1
          if ~isprop(this, s.subs)
            this.set(s.subs, v);
          else
            this = builtin('subsasgn', this, s, v);
          end
        else
          result = subsasgn(this.(s(1).subs), s(2:end), v);
        end
      else
        this = builtin('subsasgn', this, s, v);
      end
    end
  end

  methods (Static)
    [ data, options ] = extract(varargin)
  end
end
