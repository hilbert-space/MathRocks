function result = compute(type, varargin)
  result = Error.([ 'compute', type ])(varargin{:});
end
