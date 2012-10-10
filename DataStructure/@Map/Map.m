classdef Map < containers.Map
  methods
    function this = Map(keyType)
      this = this@containers.Map('KeyType', keyType, 'ValueType', 'any');
    end
  end
end
