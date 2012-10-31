function [ grid_index, grid_base ] = levels_index_cfn ( dim_num, level_max, ...
  point_num )

%*****************************************************************************80
%
%% LEVELS_INDEX_CFN indexes a sparse grid made from CFN 1D rules.
%
%  Discussion:
%
%    The sparse grid is presumed to have been created from products
%    of CLOSED FULLY NESTED 1D quadrature rules.
%
%    CFN rules include Clenshaw Curtis rules.
%
%    The sparse grid is the logical sum of product grids with total LEVEL
%    between LEVEL_MIN and LEVEL_MAX.
%
%    The necessary dimensions of GRID_INDEX can be determined by
%    calling LEVELS_INDEX_SIZE_CFN first.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    02 July 2008
%
%  Author:
%
%    John Burkardt
%
%  Reference:
%
%    Fabio Nobile, Raul Tempone, Clayton Webster,
%    A Sparse Grid Stochastic Collocation Method for Partial Differential
%    Equations with Random Input Data,
%    SIAM Journal on Numerical Analysis,
%    Volume 46, Number 5, 2008, pages 2309-2345.
%
%  Parameters:
%
%    Input, integer DIM_NUM, the spatial dimension.
%
%    Input, integer LEVEL_MAX, the maximum value of LEVEL.
%
%    Input, integer POINT_NUM, the total number of points
%    in the grids.
%
%    Output, integer GRID_INDEX(DIM_NUM,POINT_NUM), a list of
%    point indices, representing a subset of the product grid of level
%    LEVEL_MAX, representing (exactly once) each point that will show up in a
%    sparse grid of level LEVEL_MAX.
%
%    Output, integer GRID_BASE(DIM_NUM,POINT_NUM), a list of
%    the orders of the rules associated with each point and dimension.
%
  grid_index = zeros ( dim_num, point_num );
  grid_base = zeros ( dim_num, point_num );
%
%  The outer loop generates LEVELs from 0 to LEVEL_MAX.
%
  point_num2 = 0;

  for level = 0 : level_max
%
%  The middle loop generates the next partition LEVEL_1D(1:DIM_NUM)
%  that adds up to LEVEL.
%
    more = 0;
    h = 0;
    t = 0;
    level_1d = [];

    while ( 1 )

      [ level_1d, more, h, t ] = comp_next ( level, dim_num, level_1d, more, h, t );
%
%  Transform each 1D level to a corresponding 1D order.
%
      order_1d = level_to_order_closed ( dim_num, level_1d );
%
%  The product of the 1D orders gives us the number of points in this grid.
%
      order_nd = prod ( order_1d(1:dim_num) );
%
%  The inner (hidden) loop generates all points corresponding to given grid.
%
      grid_index2 = multigrid_index_cfn ( dim_num, order_1d, order_nd );
%
%  Adjust these grid indices to reflect LEVEL_MAX.
%
      grid_index2 = multigrid_scale_closed ( dim_num, order_nd, level_max, ...
        level_1d, grid_index2 );
%
%  Determine the first level of appearance of each of the points.
%
      grid_level = abscissa_level_closed_nd ( level_max, dim_num, ...
        order_nd, grid_index2 );
%
%  Only keep those points which first appear on this level.
%
      for point = 1 : order_nd

        if ( grid_level(point) == level )

          point_num2 = point_num2 + 1;

          if ( point_num < point_num2 )
            fprintf ( 1, '\n' );
            fprintf ( 1, 'LEVELS_INDEX_CFN - Fatal error!\n' );
            fprintf ( 1,'  Exceeding maximum point index POINT_NUM = %d\n', ...
              point_num );
            error ( 'LEVELS_INDEX_CFN - Fatal error!' );
          end

          grid_base(1:dim_num,point_num2) = order_1d(1:dim_num);
          grid_index(1:dim_num,point_num2) = grid_index2(1:dim_num,point);

        end

      end

      if ( ~more )
        break
      end

    end

  end

  if ( point_num2 < point_num )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'LEVELS_INDEX_CFN - Fatal error!\n' );
    fprintf ( 1, '  Set fewer points than POINT_NUM = %d\n', point_num );
    error ( 'LEVELS_INDEX_CFN - Fatal error!' );
  end

  return
end
