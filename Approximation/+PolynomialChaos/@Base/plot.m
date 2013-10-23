function plot(this, output)
  if nargin > 1
    plotCoefficients(output.coefficients);
  end

  if this.inputCount == 1
    plotBasis(this);
  end
end

function plotCoefficients(coefficients)
  termCount = size(coefficients, 1);
  coefficients = reshape(coefficients, termCount, []);
  outputCount = size(coefficients, 2);

  coefficients = flipud(abs(squeeze(coefficients(2:end, :))));

  if outputCount > 1
    xlabels = 1:outputCount;
  else
    xlabels = [];
  end

  if termCount > 2
    ylabels = termCount:-1:2;
  else
    ylabels = [];
  end

  Plot.figure(1000, 600);
  heatmap(coefficients, xlabels, ylabels, [], 'colormap', 'hot');
  Plot.title('Magnitudes of the PC coefficients');
  Plot.label('Output', 'Coefficient');
end

function plotBasis(this)
  inputCount = this.inputCount;
  order = this.order;

  %
  % Construct the RVs.
  %
  x = sym('x%d', [ 1, inputCount ]);
  assume(x, 'real');

  index = 1 + (0:order).';

  %
  % Construct the corresponding multivariate basis functions.
  %
  basis = this.constructBasis(x, order, index);
  termCount = length(basis);

  Plot.figure(1000, 600);

  nodes = this.distribution.icdf( ...
    linspace(sqrt(eps), 1 - sqrt(eps)).');

  labels = cell(1, termCount);
  for i = 1:termCount
    f = Utils.pointwiseFunction(basis(i), x);
    values = f(nodes);
    if length(values) == 1
      values = ones(size(nodes)) * values;
    end
    line(nodes, values, 'Color', Color.pick(i), 'LineWidth', 1.5);
    labels{i} = sprintf('\\Phi_{%d}', i);
  end
  name = regexp(class(this), '^[^.]*\.([^.]*)$', 'tokens');
  Plot.title('%s polynomial basis', name{1}{1});
  Plot.label('\zeta', '\Phi_i(\zeta)');
  Plot.legend(labels{:});

  ylim([ -15, 15 ]);

  line(xlim, [ 0, 0 ], 'Color', 0.3 * [ 1 1 1 ], 'LineStyle', '--');
  line([ 0, 0 ], ylim, 'Color', 0.3 * [ 1 1 1 ], 'LineStyle', '--');
end