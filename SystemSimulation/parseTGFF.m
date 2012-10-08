function [ platform, application ] = parseTGFF(file)
  fid = fopen(file);

  platform = Platform;
  application = false;

  line = fgetl(fid);
  while ischar(line)
    attrs = regexp(line, '^@(\w+) (\d+) {$', 'tokens');

    if ~isempty(attrs)
      name = attrs{1}{1};
      type = str2num(attrs{1}{2});

      if strcmp(name, 'APPLICATION')
        if application
          error('Only one application is supported at a time.')
        end
        application = parseApplication(fid);
      elseif strcmp(name, 'PROCESSOR')
        parseProcessor(platform, fid);
      end
    end

    line = fgetl(fid);
  end

  fclose(fid);
end

function application = parseApplication(fid)
  application = Application;

  line = fgetl(fid);
  while ischar(line) && isempty(regexp(line, '^}$'))
    attrs = regexp(line, '^\s*(\w+)\s+(.*)$', 'tokens');

    if ~isempty(attrs)
      command = attrs{1}{1};
      attrs = attrs{1}{2};

      switch command
      case 'TASK'
        attrs = regexp(attrs, '(\w+)\s+TYPE\s+(\d+)', 'tokens');
        if ~isempty(attrs)
          attrs = attrs{1};
          attrs{2} = str2num(attrs{2}) + 1; % Count from 1
          application.addTask(attrs{:});
        end

      case 'ARC'
        attrs = regexp(attrs, ...
          '\w+\s+FROM\s+(\w+)\s+TO\s+(\w+)\s+TYPE\s+\d+', 'tokens');
        if ~isempty(attrs)
          attrs = attrs{1};
          application.addLink(attrs{:});
        end
      end
    end

    line = fgetl(fid);
  end
end

function processor = parseProcessor(platform, fid)
  processor = platform.addProcessor;

  state = 0;

  line = fgetl(fid);
  while ischar(line) && isempty(regexp(line, '^}$'))
    switch state
    %
    % Looking for a table header.
    %
    case 0
      names = parseHeader(line);
      if ~isempty(names)
        values = zeros(0, length(names));
        state = 1;
      end

    %
    % Reading the values of the table.
    %
    case 1
      attrs = sscanf(line, '%f');

      if isempty(attrs)
        %
        % Have reached the end of the table.
        %
        configureProcessor(processor, names, values);
        state = 0;
      else
        values(end + 1, :) = attrs;
      end
    end

    line = fgetl(fid);
  end

  if state == 1
    configureProcessor(processor, names, values);
  end
end

function configureProcessor(processor, names, values)
  if length(names) ~= 4, return; end

  if ~strcmp(names{3}, 'dynamic_power')
    error('The third column is invalid.');
  end

  if ~strcmp(names{4}, 'execution_time')
    error('The fourth column is invalid.');
  end

  processor.configureTypes(values(:, 3), values(:, 4));
end

function header = parseHeader(line)
  header = {};
  chunks = regexp(line, '\s+', 'split');
  if ~isempty(chunks) && strcmp(chunks{1}, '#')
    header = chunks(2:end);
  end
end
