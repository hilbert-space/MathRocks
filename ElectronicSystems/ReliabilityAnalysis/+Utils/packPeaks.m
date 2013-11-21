function P = packPeaks(T, output)
  profileCount = size(T, 3);

  T = permute(T, [ 3, 2, 1 ]);

  peakCounts = zeros(1, output.processorCount);
  for i = 1:output.processorCount
    peakCounts(i) = length(output.peakIndex{i});
  end

  P = zeros(profileCount, sum(peakCounts));

  offset = 0;
  for i = 1:output.processorCount
    P(:, (offset + 1):(offset + peakCounts(i))) = T(:, output.peakIndex{i}, i);
    offset = offset + peakCounts(i);
  end
end
