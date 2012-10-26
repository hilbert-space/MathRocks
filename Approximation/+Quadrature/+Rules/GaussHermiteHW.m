function [ nodes, weights ] = GaussHermiteHW(order)
  %
  % References:
  %
  % [1] Heiss, F. and Winschel, V. Likelihood Approximation by Numerical
  % Integration on Sparse Grids, Journal of Econometrics, 2008.
  %
  % http://sparse-grids.de/
  %
  [ nodes, weights ] = nwspgr('gqn', 1, order);
end
