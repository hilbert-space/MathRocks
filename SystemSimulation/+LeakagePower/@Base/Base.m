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
    options
    output
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.options = options;

      filename = File.temporal([ 'LeakagePower_', ...
        DataHash({ class(this), Utils.toString(options) }), '.mat' ]);

      if File.exist(filename);
        load(filename);
      else
        [ Lgrid, Tgrid, Igrid ] = ...
          LeakagePower.Base.load(options);

        output = this.construct(Lgrid, Tgrid, Igrid, options);

        output.Lmin = min(Lgrid(:));
        output.Lmax = max(Lgrid(:));
        output.Tmin = min(Tgrid(:));
        output.Tmax = max(Tgrid(:));

        save(filename, 'output', '-v7.3');
      end

      this.output = output;
    end

    function string = toString(this)
      string = sprintf('%s(%s)', ...
        class(this), this.options.filename);
    end
  end

  methods (Abstract)
    P = evaluate(this, L, T)
  end

  methods (Abstract, Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end

  methods (Static)
    function [ Lgrid, Tgrid, Igrid ] = load(options)
      data = dlmread(options.filename, '\t', 1, 0);

      Ldata = data(:, 1);
      Tdata = Utils.toKelvin(data(:, 2));
      Idata = data(:, 3);

      LCount = options.get('LCount', 101);
      TCount = options.get('TCount', 101);

      readLCount = length(unique(Ldata));
      readTCount = length(unique(Tdata));

      LDivision = round(readLCount / LCount);
      TDivision = round(readTCount / TCount);

      LIndex = 1:LDivision:readLCount;
      TIndex = 1:TDivision:readTCount;

      Lgrid = reshape(Ldata, readTCount, readLCount);
      Tgrid = reshape(Tdata, readTCount, readLCount);
      Igrid = reshape(Idata, readTCount, readLCount);

      assert(size(unique(Lgrid, 'rows'), 1) == 1);
      assert(size(unique(Tgrid', 'rows'), 1) == 1);

      Lgrid = Lgrid(TIndex, LIndex);
      Tgrid = Tgrid(TIndex, LIndex);
      Igrid = Igrid(TIndex, LIndex);
    end
  end
end
