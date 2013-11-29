function norm = compute(type, varargin)
  norm = Norm.([ 'compute', type ])(varargin{:});
end
