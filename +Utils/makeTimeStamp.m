function stamp = makeTimeStamp
  c = clock;
  stamp = sprintf('%04d-%02d-%02d %02d-%02d-%02d', ...
    c(1), c(2), c(3), c(4), c(5), round(c(6)));
end
