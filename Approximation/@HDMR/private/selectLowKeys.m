function lowKeys = selectLowKeys(interpolants, order, index)
  lowKeys = cell(1, 0);
  for i = 1:(order - 1)
    keys = char(combnk(index, i));
    for j = 1:size(keys, 1)
      key = keys(j, :);
      if ~interpolants.isKey(key), continue; end
      lowKeys{end + 1} = key;
    end
  end
end
