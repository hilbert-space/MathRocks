classdef LeakagePower < handle
  properties (Constant)
    %
    % The nominal value of the channel length.
    %
    Lnom = 45e-9;

    %
    % The following constants are used to construct an instance
    % of the leakage model that produces `PleakPdyn' portion
    % of the given dynamic power at temperature `Tref'.
    %
    PleakPdyn = 2 / 3;
    Tref = Utils.toKelvin(120);
  end

  properties (SetAccess = 'private')
    evaluate

    Ldata
    Tdata
    Idata

    stats
  end

  methods
    function this = LeakagePower(varargin)
      [ this.evaluate, this.Ldata, this.Tdata, this.Idata, this.stats ] = ...
        LeakagePower.construct(varargin{:});
    end
  end

  methods (Static)
    [ logI, Lsym, Tsym, Ldata, Tdata, Idata, stats ] = fit(options)
    [ evaluate, Ldata, Tdata, Idata, stats ] = construct(varargin)
  end
end
