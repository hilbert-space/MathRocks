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

    function power = computeAveragePower(this)
      processorCount = length(this);

      power = 0;

      for i = 1:processorCount
        power = power + mean(this.processors{i}.dynamicPower(:));
      end

      power = power / processorCount;
    end
  end
end
