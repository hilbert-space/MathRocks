function n = gqn2_order ( l )

%*****************************************************************************80
%
%% GQN2_ORDER computes the order of a GQN rule from the level.
%
%  Discussion:
%
%    For this version of the order routine, we have
%
%      n = 2 * l - 1
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
%    John Burkardt.
%
%  Parameters:
%
%    Input, integer L, the level of the rule.  
%    1 <= L.
%
%    Output, integer N, the order of the rule.
%
  if ( l < 1 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'GQN2_ORDER - Fatal error!\n' );
    fprintf ( 1, '  1 <= L required.\n' );
    fprintf ( 1, '  Input L = %d\n', l );
    error (  'GQN2_ORDER - Fatal error!' );
  elseif ( l <= 13 )
    n = 2 * l - 1;
  else
    fprintf ( 1, '\n' );
    fprintf ( 1, 'GQN2_ORDER - Fatal error!\n' );
    fprintf ( 1, '  L <= 13 required.\n' );
    fprintf ( 1, '  Input L = %d\n', l );
    error (  'GQN2_ORDER - Fatal error!' );
  end

  return
end
