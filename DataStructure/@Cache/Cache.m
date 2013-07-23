classdef Cache < handle
  properties (SetAccess = 'protected')
    map
    hitCount
    missCount
  end

  methods
    function this = Cache()
      this.map = containers.Map('KeyType', 'char', 'ValueType', 'any');
      this.hitCount = 0;
      this.missCount = 0;
    end

    function value = fetch(this, key, compute)
      hash = Utils.computeMD5(key);

      if ~this.map.isKey(hash)
        this.map(hash) = compute(key);
        this.missCount = this.missCount + 1;
      else
        this.hitCount = this.hitCount + 1;
      end

      value = this.map(hash);
    end
  end
end
