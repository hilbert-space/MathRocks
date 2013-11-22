classdef ThermalCycling < handle
  properties (SetAccess = 'protected')
    temperature
    peakThreshold
  end

  methods
    function this = ThermalCycling(varargin)
      options = Options(varargin{:});
      if options.has('temperature')
        this.temperature = options.temperature;
      else
        this.temperature = Temperature(options);
      end
      this.peakThreshold = options.get('peakThreshold', 2);
    end

    function [ T, output ] = compute(this, Pdyn)
      [ T, output ] = this.pack(this.temperature.compute(Pdyn));
    end

    function [ T, output ] = pack(this, T)
      processorCount = size(T, 1);
      stepCount = size(T, 2);

      peakIndex = cell(1, processorCount);
      cycleIndex = cell(1, processorCount);
      cycleFraction = cell(1, processorCount);

      %
      % NOTE: We use the first temperature profile to find
      % thermal cycles.
      %
      for i = 1:processorCount
        [ peakIndex{i}, extrema ] = Utils.detectPeaks( ...
          T(i, :, 1), this.peakThreshold);
        [ cycleIndex{i}, cycleFraction{i} ] = Utils.detectCycles(extrema);
      end

      output = struct;
      output.peakIndex = peakIndex;
      output.cycleIndex = cycleIndex;
      output.cycleFraction = cycleFraction;
      output.stepCount = stepCount;

      T = Utils.packPeaks(T, peakIndex);
    end

    function T = unpack(~, output, T)
      T = Utils.unpack(T, output.peakIndex, output.stepCount);
    end

    function plot(~, output, T, varargin)
      Plot.peaks(T, output.peakIndex, varargin{:});
    end
  end
end
