function [ correlation, merging ] = correlate(~, parameter, options)
  die = options.die;
  D = die.floorplan;

  W = D(:, 1);
  H = D(:, 2);
  X = D(:, 3);
  Y = D(:, 4);

  X = X + W / 2 - die.width / 2;
  Y = Y + H / 2 - die.height / 2;

  processorCount = size(D, 1);

  globalContribution = parameter.get('globalContribution', 0);
  assert(globalContribution >= 0 && globalContribution <= 1);

  merging = false;

  if globalContribution == 1
    %
    % Global variation
    %
    V = 1;
    C = 1;
  else
    %
    % Local variations
    %
    V = (1 - globalContribution) * ones(processorCount, 1);

    I = Utils.constructPairIndex(processorCount);
    C = feval(parameter.correlation{:}, ...
      [ X(I(:, 1)).'; Y(I(:, 1)).' ], ...
      [ X(I(:, 2)).'; Y(I(:, 2)).' ]);
    C = Utils.symmetrizePairIndex(C, I);

    if globalContribution > 0
      %
      % Global variation
      %
      V(end + 1) = globalContribution;
      C(end + 1, end + 1) = 1;

      merging = true;
    end
  end

  correlation = diag(sqrt(V)) * C * diag(sqrt(V));
end
