function [ T, output ] = solve(this, Pdyn, options)
  [ T, output ] = feval( ...
    options.get('algorithm', 'condensedEquation'), this, Pdyn, options);
end
