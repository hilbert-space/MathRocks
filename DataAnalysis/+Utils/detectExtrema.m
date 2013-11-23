function [ index, extrema ] = detectExtrema(data, tolerance)
  assert(isvector(data));

  dataCount = length(data);
  extremumCount = 0;

  index = zeros(1, dataCount, 'uint16');
  extrema = zeros(1, dataCount);

  function append(j, extremum)
    extremumCount = extremumCount + 1;
    index(extremumCount) = j;
    extrema(extremumCount) = extremum;
  end

  function prepend(j, peak)
    index(2:(extremumCount + 1)) = index(1:extremumCount);
    extrema(2:(extremumCount + 1)) = extrema(1:extremumCount);
    extremumCount = extremumCount + 1;
    index(1) = j;
    extrema(1) = peak;
  end

  function replace(j, k, peak)
    index(j) = k;
    extrema(j) = peak;
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
      if this < (maxValue - tolerance)
        append(maxPosition, maxValue);
        minValue = this;
        minPosition = i;
        nextType = MIN;
      end
    elseif nextType == MIN
      if this > (minValue + tolerance)
        append(minPosition, minValue);
        maxValue = this;
        maxPosition = i;
        nextType = MAX;
      end
    else
      if this < (maxValue - tolerance)
        append(maxPosition, maxValue);
        minValue = this;
        minPosition = i;
        nextType = MIN;
        firstType = MAX;
        firstPosition = i;
      elseif this > (minValue + tolerance)
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
        if extrema(1) > maxValue
          % ... if the first minimum is larger than the last maximum, replace!
          replace(1, 1, maxValue);
        else
          % ... if not, add a point
          prepend(1, maxValue);
        end
      else
        % ... or replace the first one
        maxValue = max(maxValue, extrema(1));
        replace(1, 1, maxValue);
      end
    end

    % Ensure that we end at the end
    if index(extremumCount) ~= dataCount
      % ... if not, add a point
      append(dataCount, maxValue);
    end
  elseif nextType == MIN
    if firstPosition > 1
      if firstType == MAX
        if extrema(1) < minValue
          replace(1, 1, minValue);
        else
          prepend(1, minValue);
        end
      else
        minValue = min(minValue, extrema(1));
        replace(1, 1, minValue);
      end
    end

    if index(extremumCount) ~= dataCount
      append(dataCount, minValue);
    end
  end

  index = index(1:extremumCount);
  extrema = extrema(1:extremumCount);

  [ index, I ] = sort(index);
  extrema = extrema(I);
end
