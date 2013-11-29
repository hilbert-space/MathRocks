function [ left, right ] = detectBounds(data, varargin)
  options = Options(varargin{:});

  if ~iscell(data), data = { data }; end

  range = options.get('range', '3sigma');

  if isa(range, 'char')
    if strcmpi(range, 'unbounded')
      range = @(~, ~) [ -Inf, Inf ];
    else
      tokens = regexp(range, '^(.+)sigma$', 'tokens');
      times = str2double(tokens{1}{1});
      range = @(mu, sigma) [ mu - times * sigma, mu + times * sigma ];
    end
  end

  count = length(data);

  left = zeros(count, 1);
  right = zeros(count, 1);

  for i = 1:count
    one = data{i};

    mn = min(one);
    mx = max(one);

    mu = mean(one);
    sigma = sqrt(var(one));

    if isa(range, 'function_handle')
      r = range(mu, sigma);
    else
      r = range;
    end

    left(i) = max(mn, r(1));
    right(i) = min(mx, r(2));
  end

  left = min(left);
  right = max(right);
end
