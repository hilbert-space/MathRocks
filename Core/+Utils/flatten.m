function A = flatten(varargin)
  A = {};
  for i = 1:numel(varargin)
    if iscell(varargin{i})
      B = Utils.flatten(varargin{i}{:});
      A = [A, B{:}];
    else
      A = [A, varargin{i}];
    end
  end
end
