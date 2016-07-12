function cards = loadModelCards(filename)
  cards = struct;
  modelName = [];

  file = fopen(filename, 'r');

  line = fgetl(file);
  while ischar(line)
    if isempty(line) || ...
      ~isempty(regexp(line, '^\s*\*', 'once')) || ...
      ~isempty(regexp(line, '^\s*$', 'once'))

      line = fgetl(file);
      continue;
    end

    tokens = regexp(line, '^\s*\.model\s+(\w+)\s+(\w+)', 'tokens');
    if ~isempty(tokens)
      assert(numel(tokens) == 1 && numel(tokens{1}) == 2);
      modelName = lower(tokens{1}{1});
      modelType = lower(tokens{1}{2});
      cards.(modelName) = struct;
      cards.(modelName).type = modelType;
    end

    assert(~isempty(modelName));

    tokens = regexp(line, '(\w+)\s*=\s*([^\s]+)', 'tokens');
    for i = 1:length(tokens)
      assert(numel(tokens{i}) == 2);
      name = lower(tokens{i}{1});
      value = str2double(tokens{i}{2});
      assert(~isempty(value));
      cards.(modelName).(name) = value;
    end

    line = fgetl(file);
  end

  fclose(file);
end
