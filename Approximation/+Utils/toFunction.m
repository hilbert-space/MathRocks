function f = toFunction(p, varargin)
  [ arguments, body ] = Utils.toFunctionString(p, varargin{:});
  f =  str2func([ '@(', arguments, ')', body ]);
end
