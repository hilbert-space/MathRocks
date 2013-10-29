function driver = driver
  driver = struct('instantiate', @instantiate, 'call', @call);
end