function name = name(filename)
  [ ~, base, extension ] = fileparts(filename);
  name = [ base, extension ];
end
