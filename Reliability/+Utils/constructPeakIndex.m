function I = constructPeakIndex(output)
  I = zeros(0, 0);
  for i = 1:length(output.peaks)
    I = [ I; output.peaks{i}(:, 1) ];
  end
  I = sort(unique(I));
end
