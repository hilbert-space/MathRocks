function cce_test ( )

%*****************************************************************************80
%
%% CCE_TEST uses CCE_ORDER + CC for 1D quadrature over [0,1].
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    26 February 2014
%
%  Author:
%
%    John Burkardt
%
  fprintf ( 1, '\n' );
  fprintf ( 1, 'CCE_TEST:\n' );
  fprintf ( 1, '  CCE_ORDER + CC:\n' );
  fprintf ( 1, '  Clenshaw Curtis Exponential quadrature over [0,1]:\n' );
  fprintf ( 1, '\n' );
  fprintf ( 1, '   Level   Nodes    Estimate  Error\n' );
  fprintf ( 1, '\n' );

  d = 1;
  exact = fu_integral ( d );

  for l = 1 : 10

    n = cce_order ( l );

    [ x, w ] = cc ( n );

    fx = fu_value ( d, n, x );
    q = w' * fx;
    e = sqrt ( ( q - exact ).^2 ) / exact;

    fprintf ( '  %2d     %6d  %10.5g  %10.5g\n', l, n, q, e )

  end

  return
end
