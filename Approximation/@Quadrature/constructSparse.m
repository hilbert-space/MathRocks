function [ nodes, weights ] = constructSparse(this, options)
  ruleName = options.ruleName;
  ruleArguments = options.get('ruleArguments', {});

  switch ruleName
  case 'GaussHermiteHW'
    compute = 'gqn';
  otherwise
    compute = @(order) feval(ruleName, order, ruleArguments{:});
  end

  [ nodes, weights ] = nwspgr(compute, ...
    options.dimensionCount, options.order);
end
