function [ Lgrid, Tgrid, Igrid ] = loadLeakageData(varargin)
  options = Options(varargin{:});

  data = dlmread(options.filename, '\t', 1, 0);

  Ldata = data(:, 1);
  Tdata = Utils.toKelvin(data(:, 2)); % Comes in Celsius
  Idata = data(:, 3);

  %
  % Remove those points that are out of the desirable range.
  %
  I = [];

  if options.has('LLimit')
    I = [ I; find(Ldata < options.LLimit(1)); ...
      find(Ldata > options.LLimit(2)) ];
  end

  if options.has('TLimit')
    I = [ I; find(Tdata < options.TLimit(1)); ...
      find(Tdata > options.TLimit(2)) ];
  end

  I = unique(I);

  Ldata(I) = [];
  Tdata(I) = [];
  Idata(I) = [];

  %
  % Compute the dimensionality of the restricted grid.
  %
  readLCount = length(unique(Ldata));
  readTCount = length(unique(Tdata));

  %
  % Ensure that the maximal number of points is not violated.
  %
  LCount = options.get('LCount', readLCount);
  TCount = options.get('TCount', readTCount);

  LDivision = round(readLCount / LCount);
  TDivision = round(readTCount / TCount);

  TIndex = 1:TDivision:readTCount;
  LIndex = 1:LDivision:readLCount;

  Lgrid = reshape(Ldata, readTCount, readLCount);
  Tgrid = reshape(Tdata, readTCount, readLCount);
  Igrid = reshape(Idata, readTCount, readLCount);

  assert(size(unique(Lgrid, 'rows'), 1) == 1);
  assert(size(unique(Tgrid', 'rows'), 1) == 1);

  Lgrid = Lgrid(TIndex, LIndex);
  Tgrid = Tgrid(TIndex, LIndex);
  Igrid = Igrid(TIndex, LIndex);
end
