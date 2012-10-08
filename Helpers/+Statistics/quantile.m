function q = quantile(p)
%{
  assert(p >= 0 && p <= 1, 'The probability value is invalid.');

  if p == 0.5
    q = 0;
  elseif p > 0.5
    [ ~, q ] = ode45(@(t, x) [ x(2); x(1) * x(2)^2 ], ...
      [ 0.5 p ], [ 0; sqrt(2 * pi) ]);
    q = q(end, 1);
  else
    [ ~, q ] = ode45(@(t, x) [ x(2); x(1) * x(2)^2 ], ...
      [ 0.5 (1 - p) ], [ 0; sqrt(2 * pi) ]);
    q = -q(end, 1);
  end
%}
  q = sqrt(2) * erfinv(2 * p - 1);
end
