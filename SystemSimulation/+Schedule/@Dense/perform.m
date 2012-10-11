function perform(this)
  %
  % Some shortcuts.
  %
  tasks = this.application.tasks;
  processors = this.platform.processors;

  mapParents = this.application.mapParents;
  mapChildren = this.application.mapChildren;

  processorCount = length(processors);
  taskCount = length(tasks);

  priority = this.priority;

  mapping = this.mapping;
  order = this.order;

  startTime = this.startTime;
  executionTime = this.executionTime;

  %
  % Ensure that we have a vector of priorities.
  %
  if any(isnan(priority))
    profile = SystemProfile.Average(this.platform, this.application);
    priority = profile.taskMobility;
  end

  %
  % Obtain roots and sort them according to their priority,
  % and these tasks initialize the schedulig pool.
  %
  pool = this.application.roots;
  [ ~, I ] = sort(priority(pool));
  pool = pool(I);

  zero = zeros(1, taskCount);

  processed = zero;
  ordered = zero;

  taskTime = zero;
  processorTime = zeros(1, processorCount);

  position = 0;
  processed(pool) = 1;

  while ~isempty(pool)
    %
    % The pool is always sorted according to the priority.
    %
    id = pool(1);

    %
    % Exclude the task.
    %
    pool(1) = [];

    %
    % Append to the schedule.
    %
    position = position + 1;
    order(id) = position;
    ordered(id) = 1;

    %
    % Find the earliest processor if needed.
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
      executionTime(id) = processors{pid}.executionTime(tasks{id}.type);
    end

    finish = startTime(id) + executionTime(id);

    processorTime(pid) = finish;

    %
    % Append new tasks that are ready, and ensure that
    % there are no repetitions.
    %
    for childId = mapChildren(id)
      taskTime(childId) = max(taskTime(childId), finish);

      %
      % Do not do it twice.
      %
      if processed(childId), continue; end

      %
      % All the parents should be ordered.
      %
      ready = true;
      for parentId = mapParents(childId)
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
      % We need to insert it in the right place in order
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
          pool(end + 1) = childId;
      elseif index == 1
        pool = [ childId pool ];
      else
        pool = [ pool(1:index - 1) childId pool(index:end) ];
      end

      %
      % We are done with this one.
      %
      processed(childId) = 1;
    end
  end

  %
  % Save our achievements.
  %
  this.priority = priority;

  this.mapping = mapping;
  this.order = order;

  this.startTime = startTime;
  this.executionTime = executionTime;
end
