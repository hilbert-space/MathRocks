function [ nodes, weights ] = GaussHermite(level)
  [ nodes, weights ] = nwspgr('gqn', 1, level);
end
