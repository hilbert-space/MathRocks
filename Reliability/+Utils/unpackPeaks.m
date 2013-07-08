function T = unpackPeaks(P, output)
  profileCount = size(P, 1);
  T = zeros(output.processorCount, output.stepCount, profileCount);
  j = 0;
  for i = 1:output.processorCount
    k = size(output.peakIndex{i}, 1);
    T(i, output.peakIndex{i}, :) = P(:, (j + 1):(j + k)).';
    j = j + k;
  end
end
