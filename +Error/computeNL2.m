function error = computeNL2(observed, predicted, dimension)
  if nargin < 2, predicted = 0; end
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = Error.computeL2(observed, predicted, dimension) ./ ...
    sqrt(sum(observed.^2, dimension));
end
