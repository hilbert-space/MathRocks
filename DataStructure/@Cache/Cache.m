classdef Cache < handle
  properties (SetAccess = 'protected')
    map
  end

  methods
    function this = Cache()
      this.map = containers.Map;
    end

    function result = hasKey(this, key)
      result = this.map.isKey(Utils.computeMD5(key));
    end

    function set(this, key, value)
      this.map(Utils.computeMD5(key)) = value;
    end

    function value = get(this, key, compute)
      hash = Utils.computeMD5(key);

      if this.map.isKey(hash)
        value = this.map(hash);
      elseif nargin > 2
        value = compute(key);
        this.map(hash) = value;
      else
        value = [];
      end
    end
  end
end
