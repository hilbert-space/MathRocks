function T = unpackPeaks(P, output)
  profileCount = size(P, 1);

  T = zeros(output.processorCount, output.stepCount, profileCount);

  offset = 0;
  for i = 1:output.processorCount
    count = length(output.peakIndex{i});
    T(i, output.peakIndex{i}, :) = P(:, (offset + 1):(offset + count)).';
    offset = offset + count;
  end
end
