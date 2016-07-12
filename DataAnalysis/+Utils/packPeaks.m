function packedData = packPeaks(data, peakIndex)
  componentCount = length(peakIndex);
  profileCount = size(data, 3);

  peakCounts = zeros(1, componentCount);
  for i = 1:componentCount
    peakCounts(i) = length(peakIndex{i});
  end

  packedData = zeros(sum(peakCounts), profileCount);

  offset = 0;
  for i = 1:componentCount
    range = (offset + 1):(offset + peakCounts(i));
    packedData(range, :) = data(i, peakIndex{i}, :);
    offset = offset + peakCounts(i);
  end
end
