classdef NewtonCotesHat < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    limits
    orders
  end

  methods
    function this = NewtonCotesHat(varargin)
      this = this@Basis.Hierarchical.Global.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = configure(this, ~)
      if this.maximalLevel > 32
        warning('The maximal level is too high; changing to 32.');
        this.maximalLevel = 32;
      end

      level = this.maximalLevel;

      nodes = cell(1, level);
      weights = [];

      this.limits = zeros(1, level);
      this.orders = zeros(1, level, 'uint32');

      for i = 1:level
        switch i
        case 1
          nodes{i} = 0.5;
          this.orders(i) = uint32(1);
          this.limits(i) = 1;
        case 2
          nodes{i} = [ 0 1 ];
          this.orders(i) = uint32(3);
          this.limits(i) = 0.5;
        otherwise
          nodes{i} = (2 * (1:2^(i - 2)) - 1) * 2^(-i + 1);
          this.orders(i) = uint32(2^(i - 1) + 1);
          this.limits(i) = 1 / (double(this.orders(i)) - 1);
        end
      end
    end
  end
end
