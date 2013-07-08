function P = packPeaks(T, output)
  profileCount = size(T, 3);
  T = permute(T, [ 3, 2, 1 ]);
  P = zeros(profileCount, 0);
  for i = 1:output.processorCount
    P = [ P, T(:, output.peakIndex{i}, i) ];
  end
end
