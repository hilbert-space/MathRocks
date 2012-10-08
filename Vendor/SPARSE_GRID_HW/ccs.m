function [ x, w ] = ccs ( l )

%*****************************************************************************80
%
%% CCS computes a "slow growth" Clenshaw Curtis quadrature rule.
%
%  Discussion:
%
%    Our convention is that the abscissas are numbered from left to right.
%
%    The rule is defined on [0,1].
%
%    The integral to approximate:
%
%      Integral ( 0 <= X <= 1 ) F(X) dX
%
%    The quadrature rule:
%
%      Sum ( 1 <= I <= N ) W(I) * F ( X(I) )
%
%    The input value L requests a rule of precision at least 2*L-1.
%
%    In order to preserve nestedness, this function returns a rule
%    whose order N is the smallest value of the form 1+2^E which
%    is greater than or equal to 2*L-1.
%
%     L  2*L-1   N
%    --  -----  --
%     1      1   1
%     2      3   3
%     3      5   5
%     4      7   9
%     5      9   9
%     6     11  17
%     7     13  17
%     8     15  17
%     9     17  17
%    10     19  33
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    10 May 2012
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, integer L, the level of the rule.
%    1 <= L.
%
%    Output, real X(N,1), the abscissas.
%
%    Output, real W(N,1), the weights.
%
  if ( l < 1 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'CCU - Fatal error!\n' );
    fprintf ( 1, '  Illegal value of L = %d\n', l );
    error ( 'CCU - Fatal error!' );
  end
%
%  Find the order N that satisfies the precision requirement.
%
  if ( l == 1 )
    n = 1;
  else
    n = 3;
    while ( n < 2 * l - 1 )
      n = 2 * n - 1;
    end
  end

  w = zeros ( n, 1 );
  x = zeros ( n, 1 );
%
%  Set X.
%
  if ( n == 1 )

    x(1) = 0.0;

  else

    for i = 1 : n
      x(i) = cos ( ( n - i ) * pi / ( n - 1 ) );
    end

    x(1) = -1.0;
    if ( mod ( n, 2 ) == 1 )
      x((n+1)/2) = 0.0;
    end
    x(n) = +1.0;

  end
%
%  Set W.
%
  if ( n == 1 )

    w(1) = 2.0;

  else

    w(1:n) = 1.0;

    for i = 1 : n

      theta = ( i - 1 ) * pi / ( n - 1 );

      for j = 1 : ( n - 1 ) / 2
  
        if ( 2 * j == ( n - 1 ) )
          b = 1.0;
        else
          b = 2.0;
        end

        w(i) = w(i) - b * cos ( 2.0 * j * theta ) / ( 4 * j * j - 1 );

      end

    end

    w(1)     =       w(1)     / ( n - 1 );
    w(2:n-1) = 2.0 * w(2:n-1) / ( n - 1 );
    w(n)     =       w(n)     / ( n - 1 );

  end
%
%  Shift from [-1,+1] to [0,1].
%
  x(1:n) = 0.5 * ( x(1:n) + 1.0 );
  w(1:n) = 0.5 * w(1:n);

  return
end
