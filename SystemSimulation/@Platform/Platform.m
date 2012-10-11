classdef Platform < handle
  properties (SetAccess = 'private')
    processors
  end

  methods
    function this = Platform
    end

    function count = length(this)
      count = length(this.processors);
    end

    function processor = addProcessor(this)
      id = length(this) + 1;
      processor = Processor(id);
      this.processors{end + 1} = processor;
    end
  end
end
