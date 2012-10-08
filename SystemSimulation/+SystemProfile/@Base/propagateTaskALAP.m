function propagateTaskALAP(this, i, time)
  %
  % As later as possible.
  %
  time = max(0, time - this.taskExecutionTime(i));

  %
  % We might already have an assigned ALAP with a smaller value.
  %
  if ~(time < this.taskALAP(i)), return; end

  this.taskALAP(i) = time;

  %
  % Mobility = ALAP - ASAP.
  %
  this.taskMobility(i) = max(0, time - this.taskASAP(i));

  %
  % Shift the data-dependent tasks.
  %
  for j = this.application{i}.getParents()
    this.propagateTaskALAP(j, time);
  end
end
