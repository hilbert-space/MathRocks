function perform(this)
  %
  % Some shortcuts.
  %
  platform = this.platform;
  application = this.application;

  processorCount = length(platform);
  taskCount = length(application);

  zero = zeros(1, taskCount);

  %
  % Ensure that we have a vector of priorities.
  %
  if any(isnan(this.priority))
    profile = SystemProfile.Average(platform, application);
    this.priority = profile.taskMobility;
  end

  %
  % Obtain roots and sort them according to their priority.
  %
  ids = application.getRoots();
  [ dummy, I ] = sort(this.priority(ids));
  ids = ids(I);

  pool = application(ids);

  processed = zero;
  ordered = zero;

  taskTime = zero;
  processorTime = zeros(1, processorCount);

  position = 0;
  processed(ids) = 1;

  while ~isempty(pool)
    %
    % The pool is always sorted according to the priority.
    %
    task = pool{1};
    id = task.id;

    %
    % Exclude the task.
    %
    pool(1) = [];

    %
    % Append to the schedule.
    %
    position = position + 1;
    this.order(id) = position;
    ordered(id) = 1;

    %
    % Find the earliest processor if needed.
    %
    pid = this.mapping(id);
    if isnan(pid)
      pid = 1;
      earliestTime = processorTime(1);
      for i = 2:processorCount
        if processorTime(i) < earliestTime
          earliestTime = processorTime(i);
          pid = i;
        end
      end
      this.mapping(id) = pid;
    end

    this.startTime(id) = max(taskTime(id), processorTime(pid));

    if isnan(this.executionTime(id))
      this.executionTime(id) = platform{pid}.executionTime(task.type);
    end

    finish = this.startTime(id) + this.executionTime(id);

    processorTime(pid) = finish;

    %
    % Append new tasks that are ready, and ensure that
    % there are no repetitions.
    %
    for i = task.getChildren()
      child = application{i};
      taskTime(child.id) = max(taskTime(child.id), finish);

      %
      % Do not do it twice.
      %
      if processed(child.id), continue; end

      %
      % All the parents should be ordered.
      %
      ready = true;
      for j = child.getParents()
        if ~ordered(application{j}.id)
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
      childPriority = this.priority(child.id);
      for competitor = pool
        competitor = competitor{1};
        if this.priority(competitor.id) > childPriority
          break;
        end
        index = index + 1;
      end
      if index > length(pool), pool{end + 1} = child;
      elseif index == 1, pool = { child pool{:} };
      else pool = { pool{1:index - 1} child pool{index:end} };
      end

      %
      % We are done with this one.
      %
      processed(child.id) = 1;
    end
  end
end
