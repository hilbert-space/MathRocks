function [ T, output ] = compute(this, Pdyn, varargin)
  options = Options(varargin{:});
  [ T, output ] = feval( ...
    options.get('algorithm', 'condensedEquation'), this, Pdyn, options);
end
