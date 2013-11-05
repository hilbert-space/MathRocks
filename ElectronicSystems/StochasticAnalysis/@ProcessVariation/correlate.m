function [ correlation, contribution, merging ] = correlate(~, parameter, options)
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
    correlation = 1;
    contribution = 1;
  else
    %
    % Local variations
    %
    I = Utils.constructPairIndex(processorCount);
    correlation = feval(parameter.correlation{:}, ...
      [ X(I(:, 1)).'; Y(I(:, 1)).' ], ...
      [ X(I(:, 2)).'; Y(I(:, 2)).' ]);
    correlation = Utils.symmetrizePairIndex(correlation, I);

    contribution = (1 - globalContribution) * ones(processorCount, 1);

    if globalContribution > 0
      %
      % Global variation
      %
      correlation(end + 1, end + 1) = 1;
      contribution(end + 1) = globalContribution;

      merging = true;
    end
  end
end
