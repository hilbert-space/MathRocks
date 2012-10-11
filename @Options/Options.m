classdef Options < dynamicprops
  methods
    function this = Options(varargin)
      this.update(varargin{:});
    end

    function value = get(this, name, default)
      if isprop(this, name)
        value = this.(name);
      elseif isa(default, 'function_handle')
        value = default();
      else
        value = default;
      end
    end

    function set(this, name, value)
      if ~isprop(this, name), this.addprop(name); end
      this.(name) = value;
    end
  end

  methods (Static)
    [ data, options ] = extract(varargin)
  end
end
