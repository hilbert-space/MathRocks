classdef Base < Basis.Hierarchical.Base
  properties (SetAccess = 'protected')
    nodes
    weights
    counts
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Base(options);

      [this.nodes, this.weights] = this.configure(options);

      this.counts = zeros(1, length(this.nodes), 'uint32');

      for i = 1:length(this.nodes)
        this.counts(i) = numel(this.nodes{i});
      end
    end
  end

  methods (Abstract, Access = 'protected')
    [nodes, weights] = configure(this, options)
  end
end
