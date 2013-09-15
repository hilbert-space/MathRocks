classdef Polynomial < Fitting
  methods
    function this = Polynomial(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = construct(this, target, parameters, options)

    function target = evaluate(this, output, parameters)
      target = output.evaluate(parameters{:});
    end
  end
end
