function peaks = detectPeaks(v, delta)
  peaks = zeros(0, 2);

  mn = Inf;
  mx = -Inf;
  mnpos = 0;
  mxpos = 0;
  first_pos = 0;

  UNDEFINED = 0;
  MIN = 1;
  MAX = 2;

  look_for = UNDEFINED;
  first_is = UNDEFINED;

  count = length(v);

  for i = 1:count
    this = v(i);

    if this >= mx, mx = this; mxpos = i; end
    if this <= mn, mn = this; mnpos = i; end

    if look_for == MAX
      if this < (mx - delta)
        peaks(end + 1, :) = [ mxpos mx ];
        mn = this;
        mnpos = i;
        look_for = MIN;
      end
    elseif look_for == MIN
      if this > (mn + delta)
        peaks(end + 1, :) = [ mnpos mn ];
        mx = this;
        mxpos = i;
        look_for = MAX;
      end
    else
      if this < (mx - delta)
        peaks(end + 1, :) = [ mxpos mx ];
        mn = this;
        mnpos = i;
        look_for = MIN;
        first_is = MAX;
        first_pos = i;
      elseif this > (mn + delta)
        peaks(end + 1, :) = [ mnpos mn ];
        mx = this;
        mxpos = i;
        look_for = MAX;
        first_is = MIN;
        first_pos = i;
      end
    end
  end

  if look_for == MAX
    % Ensure that we start from the very beginning
    if first_pos > 1
      if first_is == MIN
        if peaks(1, 2) > mx
          % ... if the first minima is larger than the last maxima, replace!
          peaks(1, :) = [ 1 mx ];
        else
          % ... if not, add a point
          peaks = [ 1 mx; peaks ];
        end
      else
        % ... or replace the first one
        mx = max([ mx, peaks(1, 2) ]);
        peaks(1, :) = [ 1 mx ];
      end
    end

    % Ensure that we end in the end
    if peaks(end, 1) ~= count
      % If not, add a point
      peaks(end + 1, :) = [ count mx ];
    end
  elseif look_for == MIN
    if first_pos > 1
      if first_is == MAX
        if peaks(1, 2) < mn
          peaks(1, :) = [ 1 mn ];
        else
          peaks = [ 1 mn; peaks ];
        end
      else
        mn = min([ mn, peaks(1, 2) ]);
        peaks(1, :) = [ 1 mn ];
      end
    end

    if peaks(end, 1) ~= count
      peaks(end + 1, :) = [ count mn ];
    end
  end
end
