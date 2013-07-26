function [ V, T, I ] = loadLeakageData(varargin)
  options = Options(varargin{:});

  data = dlmread(options.filename, '\t', 1, 0);

  V = data(:, 1);
  T = Utils.toKelvin(data(:, 2)); % Comes in Celsius
  I = data(:, 3);

  %
  % Remove those points that are out of the desirable range.
  %
  J = [];

  if options.has('VRange')
    J = [ J; find(V < options.VRange(1)); ...
      find(V > options.VRange(2)) ];
  end

  if options.has('TRange')
    J = [ J; find(T < options.TRange(1)); ...
      find(T > options.TRange(2)) ];
  end

  J = unique(J);

  V(J) = [];
  T(J) = [];
  I(J) = [];

  %
  % Compute the dimensionality of the restricted grid.
  %
  readVCount = length(unique(V));
  readTCount = length(unique(T));

  %
  % Ensure that the maximal number of points is not violated.
  %
  VCount = options.get('VCount', readVCount);
  TCount = options.get('TCount', readTCount);

  VDivision = round(readVCount / VCount);
  TDivision = round(readTCount / TCount);

  VIndex = 1:VDivision:readVCount;
  TIndex = 1:TDivision:readTCount;

  V = reshape(V, readTCount, readVCount);
  T = reshape(T, readTCount, readVCount);
  I = reshape(I, readTCount, readVCount);

  assert(size(unique(V, 'rows'), 1) == 1);
  assert(size(unique(T', 'rows'), 1) == 1);

  V = V(TIndex, VIndex);
  T = T(TIndex, VIndex);
  I = I(TIndex, VIndex);
end
