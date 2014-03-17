function gqn2_sparse_test ( )

%*****************************************************************************80
%
%% GQN2_SPARSE_TEST uses the GQN and GQN2_ORDER functions.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    07 February 2014
%
%  Author:
%
%    John Burkardt
%
%  Local parameters:
%
%    Local, integer D, the spatial dimension.
%
%    Local, integer MAXK, the maximum level to check.
%
  d = 2;
  maxk = 4;

  fprintf ( 1, '\n' );
  fprintf ( 1, 'GQN2_SPARSE_TEST:\n' );
  fprintf ( 1, '  GQN sparse grid:\n' );
  fprintf ( 1, '  Gauss-Hermite sparse grids over (-oo,+oo).\n' );
  fprintf ( 1, '  Use GQN2_ORDER, the growth rule N = 2 * L - 1.\n' );

  for k = 2 : maxk

    fprintf ( 1, '\n' );
    fprintf ( 1, '   D  Level   Nodes    SG error    MC error\n' );
    fprintf ( 1, '\n' );

    [x w] = nwspgr ( 'gqn', d, k );

    fprintf( '  %2d     %2d  %6d  %10.5g  %10.5g\n', d, k, numnodes, SGerror, Simerror )

  end

  return
end
