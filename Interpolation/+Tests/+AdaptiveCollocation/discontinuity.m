function discontinuity
  clear all;
  setup;

  f = 2;
  x0 = 0.05;
  dx = 0.2;
  t = 0:0.001:10;

  options = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  z = -1:0.1:1;

  steps = length(t);
  samples = length(z);

  Y = zeros(steps, samples);

  tic;
  for i = 1:samples
    [ ~, y ] = ode45(@rightHandSide, t, ...
      [ x0 + dx * z(i), 0 ], options, f);
    Y(:, i) = y(:, 1);
  end
  fprintf('Simulation time for %d samples: %.2f s\n', samples, toc);

  [ T, Z ] = meshgrid(t, z);

  meshc(T, Z, transpose(Y));
  view([ 35, 45 ]);

  xlabel('Time');
  ylabel('Uncertain parameter');
  zlabel('Solution');
end

function dy = rightHandSide(t, y, f)
  dy = [ y(2, :); - f * y(2, :) - (35 / 2) * y(1, :).^3 + (15 / 2) * y(1, :) ];
end
