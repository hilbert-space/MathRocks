function [ V, C ] = correlate(this, options)
  die = options.die;
  D = die.floorplan;

  W = D(:, 1);
  H = D(:, 2);
  X = D(:, 3);
  Y = D(:, 4);

  X = X + W / 2 - die.width / 2;
  Y = Y + H / 2 - die.height / 2;

  dimensionCount = size(D, 1);

  %
  % Local variation
  %
  V = (1 - options.globalPortion) * ones(dimensionCount, 1);

  I = Utils.constructPairIndex(dimensionCount);
  C = feval(options.kernel{:}, ...
    [ X(I(:, 1)).'; Y(I(:, 1)).' ], ...
    [ X(I(:, 2)).'; Y(I(:, 2)).' ]);
  C = Utils.symmetrizePairIndex(C, I);

  %
  % Global variation
  %
  V(end + 1) = options.globalPortion;
  C(end + 1, end + 1) = 1;
end
