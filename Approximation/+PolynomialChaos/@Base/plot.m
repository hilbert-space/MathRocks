function plot(this)
  dimension = this.inputCount;
  order = this.order;

  assert(dimension == 1);

  %
  % Construct the RVs.
  %
  for i = 1:dimension
    x(i) = sympoly([ 'x', num2str(i) ]);
  end

  index = 1 + (0:order).';

  %
  % Construct the corresponding multivariate basis functions.
  %
  basis = this.constructBasis(x, order, index);
  terms = length(basis);

  figure;

  nodes = linspace(-4, 4);

  labels = {};
  for i = 1:terms
    f = Utils.toFunction(basis(i), x, 'columns');
    values = f(nodes);
    if length(values) == 1
      values = ones(size(nodes)) * values;
    end
    norm = this.computeNormalizationConstant(i, index);
    line(nodes, values, 'Color', Color.pick(i));
    labels{end + 1} = sprintf('\\Phi_%d', i);
  end
  name = regexp(class(this), '^[^.]*\.([^.]*)$', 'tokens');
  Plot.title('%s polynomial basis', name{1}{1});
  Plot.label('\zeta', '\Phi_i(\zeta)');
  Plot.legend(labels{:});

  ylim([ -15, 15 ]);

  line(xlim, [ 0, 0 ], 'Color', 0.3 * [ 1 1 1 ], 'LineStyle', '--');
  line([ 0, 0 ], ylim, 'Color', 0.3 * [ 1 1 1 ], 'LineStyle', '--');
end
