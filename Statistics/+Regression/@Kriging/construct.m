function [model, performance] = construct(this, options)
  inputCount = options.get('inputCount', 1);

  verbose = @(varargin) [];
  if options.get('verbose', false)
    verbose = @(varargin) fprintf(varargin{:});
  end

  %
  % Deciding about the input data.
  %
  if options.has('nodes')
    nodes = options.nodes;
    nodeCount = size(nodes, 1);
  else
    nodeCount = options.get('nodeCount', 10 * inputCount);
    nodes = lhsdesign(nodeCount, inputCount);
  end
  %
  % Deciding about the output data.
  %
  if options.has('responses')
    responses = options.responses;
  else
    target = options.target;
    verbose('Kriging: collecting data (%d nodes)...\n', nodeCount);
    time = tic;
    responses = target(nodes);
    verbose('Kriging: done in %.2f seconds.\n', toc(time));
  end

  regression  = options.get('regressionModel',  @regpoly0);
  correlation = options.get('correlationModel', @corrgauss);

  parameters  = options.get('parameters', 1);
  lowerBound  = options.get('lowerBound', []);
  upperBound  = options.get('upperBound', []);

  if isempty(lowerBound) || isempty(upperBound)
    arguments = { parameters };
  else
    arguments = { parameters, lowerBound, upperBound };
  end

  verbose('Kriging: processing the data (%d inputs, %d outputs)...\n', ...
    inputCount, size(responses, 2));
  time = tic;

  [this.model, this.performance] = dacefit(nodes, responses, ...
    regression, correlation, arguments{:});

  verbose('Kriging: done in %.2f seconds.\n', toc(time));
end
