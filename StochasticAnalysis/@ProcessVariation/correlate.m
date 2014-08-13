function correlation = correlate(~, parameter, options)
  die = options.die;
  D = die.floorplan;

  W = D(:, 1);
  H = D(:, 2);
  X = D(:, 3);
  Y = D(:, 4);

  X = X + W / 2 - die.width / 2;
  Y = Y + H / 2 - die.height / 2;

  I = Utils.constructPairIndex(size(D, 1));
  correlation = feval(parameter.correlation, ...
    [ X(I(:, 1)).'; Y(I(:, 1)).' ], ...
    [ X(I(:, 2)).'; Y(I(:, 2)).' ]);
  correlation = Utils.symmetrizePairIndex(correlation, I);
end
