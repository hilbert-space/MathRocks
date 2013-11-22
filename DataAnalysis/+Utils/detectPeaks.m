function [ index, peaks ] = detectPeaks(data, delta)
  dataCount = length(data);
  peakCount = 0;

  index = zeros(1, dataCount, 'uint16');
  peaks = zeros(1, dataCount);

  function append(j, peak)
    peakCount = peakCount + 1;
    index(peakCount) = j;
    peaks(peakCount) = peak;
  end

  function prepend(j, peak)
    index(2:(peakCount + 1)) = index(1:peakCount);
    peaks(2:(peakCount + 1)) = peaks(1:peakCount);
    peakCount = peakCount + 1;
    index(1) = j;
    peaks(1) = peak;
  end

  function replace(j, k, peak)
    index(j) = k;
    peaks(j) = peak;
  end

  minValue = Inf;
  maxValue = -Inf;
  minPosition = 0;
  maxPosition = 0;
  firstPosition = 0;

  UNDEFINED = 0; MIN = 1; MAX = 2;

  nextType = UNDEFINED;
  firstType = UNDEFINED;

  for i = 1:dataCount
    this = data(i);

    if this >= maxValue, maxValue = this; maxPosition = i; end
    if this <= minValue, minValue = this; minPosition = i; end

    if nextType == MAX
      if this < (maxValue - delta)
        append(maxPosition, maxValue);
        minValue = this;
        minPosition = i;
        nextType = MIN;
      end
    elseif nextType == MIN
      if this > (minValue + delta)
        append(minPosition, minValue);
        maxValue = this;
        maxPosition = i;
        nextType = MAX;
      end
    else
      if this < (maxValue - delta)
        append(maxPosition, maxValue);
        minValue = this;
        minPosition = i;
        nextType = MIN;
        firstType = MAX;
        firstPosition = i;
      elseif this > (minValue + delta)
        append(minPosition, minValue);
        maxValue = this;
        maxPosition = i;
        nextType = MAX;
        firstType = MIN;
        firstPosition = i;
      end
    end
  end

  if nextType == MAX
    % Ensure that we start from the very beginning
    if firstPosition > 1
      if firstType == MIN
        if peaks(1) > maxValue
          % ... if the first minimum is larger than the last maximum, replace!
          replace(1, 1, maxValue);
        else
          % ... if not, add a point
          prepend(1, maxValue);
        end
      else
        % ... or replace the first one
        maxValue = max(maxValue, peaks(1));
        replace(1, 1, maxValue);
      end
    end

    % Ensure that we end at the end
    if index(peakCount) ~= dataCount
      % ... if not, add a point
      append(dataCount, maxValue);
    end
  elseif nextType == MIN
    if firstPosition > 1
      if firstType == MAX
        if peaks(1) < minValue
          replace(1, 1, minValue);
        else
          prepend(1, minValue);
        end
      else
        minValue = min(minValue, peaks(1));
        replace(1, 1, minValue);
      end
    end

    if index(peakCount) ~= dataCount
      append(dataCount, minValue);
    end
  end

  index = index(1:peakCount);
  peaks = peaks(1:peakCount);

  [ index, I ] = sort(index);
  peaks = peaks(I);
end
