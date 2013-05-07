classdef Base < handle
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

  properties (SetAccess = 'protected')
    filename
    output
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.filename = options.filename;

      filename = File.temporal([ 'LeakagePower_', ...
        DataHash({ class(this), Utils.toString(options) }), '.mat' ]);

      if File.exist(filename);
        load(filename);
      else
        [ Ldata, Tdata, Idata ] = LeakagePower.Base.load(this.filename);
        output = this.construct(Ldata, Tdata, Idata, options);
        save(filename, 'output', '-v7.3');
      end

      this.output = output;
    end
  end

  methods (Abstract)
    P = evaluate(this, L, T)
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end

  methods (Static)
    function [ Ldata, Tdata, Idata ] = load(filename)
      data = dlmread(filename, '\t', 1, 0);
      Ldata = data(:, 1);
      Tdata = Utils.toKelvin(data(:, 2));
      Idata = data(:, 3);
    end
  end
end
