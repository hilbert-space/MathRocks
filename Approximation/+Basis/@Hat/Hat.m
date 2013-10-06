classdef Hat < Basis.Base
  methods
    function this = Hat(varargin)
      this = this@Basis.Base(varargin{:});
    end
  end

  methods
    function result = evaluate(~, y, i, j)
      if i == 1
        mi = 1;
      else
        mi = 2^(i - 1) + 1;
      end
      if mi == 1
        yij = 0.5;
      else
        yij = (j - 1) / (mi - 1);
      end
      result = zeros(size(y));
      I = abs(y - yij) < 1 / (mi - 1);
      result(I) = 1 - (mi - 1) * abs(y(I) - yij);
    end

    function [ Y, J ] = computeNodes(this, i)
      if i == 1
        J = 1;
        Y = 0.5;
      else
        J = this.constructOrderIndex(i);
        Y = (J - 1) ./ 2^(i - 1);
      end
    end

    function [ Y, J ] = computeChildNodes(~, i, j)
      switch i
      case 1
        assert(j == 1);
        J = [ 1; 3 ];
        Y = [ 0; 1 ];
      case 2
        if j == 1
          J = 2;
          Y = 0.25;
        else
          assert(j == 3);
          J = 4;
          Y = 0.75;
        end
      otherwise
        J = [ 2 * j - 2; 2 * j ];
        Y = (J - 1) / 2^i;
      end
    end

    function J = constructOrderIndex(this, i)
      switch i
      case 1
        J = 1;
      case 2
        J = [ 1; 3 ];
      case 3
        J = [ 2; 4 ];
      otherwise
        J = this.constructOrderIndex(i - 1);
        J = [ 2 * J - 2; 2 * J ];
      end
    end
  end
end
