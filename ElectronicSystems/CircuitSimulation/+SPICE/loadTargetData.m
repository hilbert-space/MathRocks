function targetData = loadTargetData(targetName, filename)
  x = loadsig(filename);

  switch File.extension(filename)
  case '.sw0'
    for i = 1:length(x)
      if ~strcmpi(x(i).name, targetName), continue; end
      targetData = x(i).data(:);
      return;
    end
  case '.tr0'
    for i = 1:length(x)
      if strcmpi(x(i).name, targetName) == 0, continue; end
      targetData = x(i).data;
      targetData = targetData(floor(size(targetData, 1) / 3):end, :);
      targetData = mean(targetData, 1)';
      return;
    end
  otherwise
    assert(false);
  end

  assert(false);
end
