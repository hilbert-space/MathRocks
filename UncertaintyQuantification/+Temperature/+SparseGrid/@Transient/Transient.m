classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.SparseGrid.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient(options);
      this = this@Temperature.SparseGrid.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.interpolate(varargin{:});
    end
  end
end
