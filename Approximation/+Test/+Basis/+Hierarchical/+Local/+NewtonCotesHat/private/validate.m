function validate(basis, i, j)
  if isa(i, 'sym') || isa(j, 'sym'), return; end
  J = basis.computeLevelOrders(i);
  if ismember(j, J), return; end
  error('The input arguments are invalid.');
end
