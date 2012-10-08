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

    function varargout = subsref(this, S)
      switch S(1).type
      case '{}'
        o = this.processors;
      otherwise
        o = this;
      end
      varargout = cell(1, nargout);
      if nargout == 0
        builtin('subsref', o, S);
      else
        [ varargout{:} ] = builtin('subsref', o, S);
      end
    end

    function processor = addProcessor(this)
      id = length(this) + 1;
      processor = Processor(id);
      this.processors{end + 1} = processor;
    end
  end
end
