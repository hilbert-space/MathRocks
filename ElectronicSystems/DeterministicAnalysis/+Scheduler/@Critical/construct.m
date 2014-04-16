function [ mapping, priority, order, startTime, executionTime ] = ...
  construct(this, penalize)

  processorCount = length(this.platform);
  taskCount = length(this.application);

  links = this.application.links;

  startTime = NaN(1, taskCount);
  executionTime = NaN(1, taskCount);

  %
  % Initialize the scheduling pool
  %
  pool = this.application.roots;

  processed = false(1, taskCount);
  ordered = false(1, taskCount);

  taskTime = zeros(1, taskCount);
  processorTime = zeros(processorCount, 1);
  processorEnergy = zeros(processorCount, 1);

  position = 0;
  processed(pool) = true;

  %
  % Static and dynamic criticality
  %
  % Reference:
  %
  % Y. Xie et al. "Temperature-aware task allocation and scheduling
  % for embedded MPSoC design." Journal of VLSI Signal Processing,
  % 45(3):177–189, 2006.
  %
  powerMapping = this.powerMapping;
  timeMapping = this.timeMapping;
  staticCriticality = this.profile.taskStaticCriticality;

  %
  % NOTE: All input parameters are ignored.
  %
  mapping = zeros(1, taskCount);
  priority = zeros(1, taskCount);
  order = zeros(1, taskCount);

  while ~isempty(pool)
    poolSize = length(pool);

    dynamicCriticality = -Inf(poolSize, processorCount);
    for i = 1:poolSize
      id = pool(i);
      for pid = 1:processorCount
        % Time
        earliestTime = max(taskTime(id), processorTime(pid));
        time = earliestTime + timeMapping(id, pid);

        energy = processorEnergy;
        energy(pid) = energy(pid) + ...
          timeMapping(id, pid) * powerMapping(id, pid);

        dynamicCriticality(i, pid) = ...
          + staticCriticality(id) ...
          - timeMapping(id, pid) ...
          - earliestTime ...
          - penalize(energy, time);
      end
    end

    [ ~, I ] = max(dynamicCriticality(:));
    pid = ceil(I / poolSize);
    i = I - poolSize * (pid - 1);

    %
    % Fetch the chosen task from the pool
    %
    id = pool(i);
    pool(i) = [];

    %
    % Append the task to the schedule
    %
    position = position + 1;

    mapping(id) = pid;
    priority(id) = position; % just by the order
    order(id) = position;
    ordered(id) = true;

    startTime(id) = max(taskTime(id), processorTime(pid));

    if isnan(executionTime(id))
      executionTime(id) = timeMapping(id, pid);
    end

    finish = startTime(id) + executionTime(id);

    processorTime(pid) = finish;
    processorEnergy(pid) = processorEnergy(pid) + ...
      timeMapping(id, pid) * powerMapping(id, pid);

    %
    % Append the new tasks that are ready
    %
    for childId = find(links(id, :)) % children
      taskTime(childId) = max(taskTime(childId), finish);

      %
      % Avoid doing it twice
      %
      if processed(childId), continue; end

      %
      % NOTE: All the parents should be ordered.
      %
      ready = true;
      for parentId = transpose(find(links(:, childId))) % parents
        if ~ordered(parentId)
          ready = false;
          break;
        end
      end

      %
      % Is it ready or should we wait for another parent?
      %
      if ~ready, continue; end

      pool = [ pool, childId ];
      processed(childId) = true;
    end
  end
end
