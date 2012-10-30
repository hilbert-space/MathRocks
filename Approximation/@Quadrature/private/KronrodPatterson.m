function [ nodes, weights ] = KronrodPatterson(level)
  [ nodes, weights ] = nwspgr('kpu', 1, level);
end
