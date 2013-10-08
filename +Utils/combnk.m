function combs = combnk(n, k)
  if k > n, error('k must be less than or equal to n.'); end

  %
  % NOTE: Other types can be troublesome.
  %
  m = double(n);

  %
  % Several shortcuts.
  %
  if k == 1
    combs = (1:n).';
    return;
  elseif k == n
    combs = 1:n;
    return;
  elseif k == 2 && n > 2
    count = (m - 1) * m / 2;
    I = cumsum((m - 1):-1:2) + 1;
    combs = zeros(count, 2, class(n));
    combs(:, 2) = 1;
    combs(1, :) = [ 1 2 ];
    combs(I, 1) = 1;
    combs(I, 2) = -((n - 3):-1:0);
    combs = cumsum(combs);
    return
  end

  I = 1:k;
  limit = k;
  increment = 1;

  count = prod((m - k + 1):m) / (prod(1:k));
  combs = zeros(round(count), k, class(n));

  combs(1, :) = I;

  for i = 2:(count - 1);
    if logical((increment + limit) - n) % Is logical necessary for single?
      stop = increment;
      flag = 0;
    else
      stop = 1;
      flag = 1;
    end

    for j = 1:stop
      %
      % NOTE: Faster than a vector assignment.
      %
      I(k  + j - increment) = limit + j;
    end

    combs(i, :) = I;
    increment = increment * flag + 1;
    limit = I(k - increment + 1 );
  end

  combs(i + 1, :) = (n - k + 1):n;
end
