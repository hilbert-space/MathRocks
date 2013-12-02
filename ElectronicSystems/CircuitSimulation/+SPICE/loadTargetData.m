function data = loadTargetData(circuit, varargin)
  x = loadsig(circuit.targetFilename);

  switch File.extension(circuit.targetFilename)
  case '.sw0'
    for i = 1:length(x)
      if ~strcmpi(x(i).name, circuit.targetName), continue; end
      data = x(i).data(:);
      return;
    end
  case '.tr0'
    for i = 1:length(x)
      if strcmpi(x(i).name, circuit.targetName) == 0, continue; end
      data = x(i).data;
      data = data(floor(size(data, 1) / 3):end, :);
      data = mean(data, 1)';
      return;
    end
  otherwise
    assert(false);
  end

  assert(false);
end
