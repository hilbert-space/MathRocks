function [mapping, priority, order, startTime, executionTime] = ...
  construct(this, mapping, priority, order, startTime, executionTime)

  processorCount = length(this.platform);
  taskCount = length(this.application);

  if nargin < 2 || isempty(mapping)
    mapping = zeros(1, taskCount);
  end

  if nargin < 3 || isempty(priority)
    priority = this.profile.taskMobility;
  end

  if nargin < 4 || isempty(order)
    order = zeros(1, taskCount);
  end

  if nargin < 5 || isempty(startTime)
    startTime = NaN(1, taskCount);
  else
    assert(false);
  end

  if nargin < 6 || isempty(executionTime)
    executionTime = NaN(1, taskCount);
  end

  %
  % Initialize the scheduling pool
  %
  pool = this.application.roots;
  [~, I] = sort(priority(pool));
  pool = pool(I);

  processed = false(1, taskCount);
  ordered = false(1, taskCount);

  taskTime = zeros(1, taskCount);
  processorTime = zeros(1, processorCount);

  position = 0;
  processed(pool) = true;

  childMapping = this.childMapping;
  parentMapping = this.parentMapping;
  timeMapping = this.timeMapping;

  while ~isempty(pool)
    %
    % Fetch the first task from the pool, which is always sorted
    % according to the priority.
    %
    id = pool(1);
    pool(1) = [];

    %
    % Append the task to the schedule
    %
    position = position + 1;

    order(id) = position;
    ordered(id) = true;

    %
    % Decide on the processor for the task
    %
    pid = mapping(id);
    if pid == 0
      pid = 1;
      earliestTime = processorTime(1);
      for i = 2:processorCount
        if processorTime(i) < earliestTime
          earliestTime = processorTime(i);
          pid = i;
        end
      end
      mapping(id) = pid;
    end

    startTime(id) = max(taskTime(id), processorTime(pid));

    if isnan(executionTime(id))
      executionTime(id) = timeMapping(id, pid);
    end

    finish = startTime(id) + executionTime(id);

    processorTime(pid) = finish;

    %
    % Append the new tasks that are ready
    %
    for childId = childMapping{id} % children
      taskTime(childId) = max(taskTime(childId), finish);

      %
      % Avoid doing it twice
      %
      if processed(childId), continue; end

      %
      % NOTE: All the parents should be ordered.
      %
      ready = true;
      for parentId = parentMapping{childId} % parents
        if ~ordered(parentId)
          ready = false;
          break;
        end
      end

      %
      % Is it ready or should we wait for another parent?
      %
      if ~ready, continue; end

      %
      % NOTE: We need to insert it in the right place in order
      % to keep the pool sorted by the priority.
      %
      index = 1;
      childPriority = priority(childId);
      for competitorId = pool
        if priority(competitorId) > childPriority
          break;
        end
        index = index + 1;
      end
      if index > length(pool)
        pool = [pool, childId];
      elseif index == 1
        pool = [childId, pool];
      else
        pool = [pool(1:(index - 1)), childId, pool(index:end)];
      end

      processed(childId) = true;
    end
  end
end
