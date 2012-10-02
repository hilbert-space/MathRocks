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
  end

  methods (Static)
    [ data, options ] = extract(varargin)
  end
end
