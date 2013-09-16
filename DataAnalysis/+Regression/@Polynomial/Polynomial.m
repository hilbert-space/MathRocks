classdef Polynomial < Fitting
  methods
    function this = Polynomial(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = construct( ...
      this, targetData, parameterData, options)

    function target = evaluate(this, output, varargin)
      target = output.evaluate(varargin{:});
    end
  end
end
