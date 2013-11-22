function data = unpackPeaks(packedData, peakIndex, stepCount)
  componentCount = length(peakIndex);
  profileCount = size(packedData, 2);

  peakCounts = zeros(1, componentCount);
  for i = 1:componentCount
    peakCounts(i) = length(peakIndex{i});
  end

  data = zeros(componentCount, stepCount, profileCount);

  offset = 0;
  for i = 1:componentCount
    range = (offset + 1):(offset + peakCounts(i));
    T(i, peakIndex{i}, :) = packedData(range, :);
    offset = offset + peakCount(i);
  end
end
