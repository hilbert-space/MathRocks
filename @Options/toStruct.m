function s = toStruct(this)
  s = struct;

  names = properties(this);
  for i = 1:length(names)
    value = this.(names{i});

    if isa(value, 'Options')
      error('Nested Options are not supported.');
    end

    s.(names{i}) = this.(names{i});
  end
end
