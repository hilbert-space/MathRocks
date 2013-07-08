function I = constructPeakIndex(output)
  I = zeros(0, 0);
  for i = 1:output.processorCount
    I = [ I; output.peakIndex{i}(:) ];
  end
  I = sort(unique(I));
end
