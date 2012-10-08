classdef Processor < handle
  properties (SetAccess = 'private')
    id

    dynamicPower
    executionTime
  end

  methods
    function this = Processor(id)
      this.id = id;

      this.dynamicPower = zeros(0, 0);
      this.executionTime = zeros(0, 0);
    end

    function configureTypes(this, dynamicPower, executionTime)
      assert(length(dynamicPower) == length(executionTime), ...
        'The power and time values do not match each other.');

      this.dynamicPower = dynamicPower;
      this.executionTime = executionTime;
    end

    function count = typeCount(this)
      count = length(this.dynamicPower);
    end
  end
end
