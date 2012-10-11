classdef Map < containers.Map
  methods
    function this = Map(keyType, valueType)
      if nargin < 2, valueType = 'any'; end
      this = this@containers.Map('KeyType', keyType, 'ValueType', valueType);
    end
  end
end
