function [ bestOffset, offsets, RMSEs ] = match(observed, predicted, offset)
  if nargin < 3, offset = 5; end

  offsets = -offset:offset;

  count = length(offsets);

  RMSEs = zeros(1, count);

  observed = observed(:);
  predicted = predicted(:);

  for i = 1:count
    offset = offsets(i);

    if offset < 0
      shifted = [ predicted((end + offset + 1):end); predicted(1:(end + offset)) ];
    else
      shifted = [ predicted((offset + 1):end); predicted(1:offset) ];
    end

    RMSEs(i) = Stats.RMSE(observed, shifted);
  end

  [ ~, i ] = min(RMSEs);

  bestOffset = offsets(i);
end
