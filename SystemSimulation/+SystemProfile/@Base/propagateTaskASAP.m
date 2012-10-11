function propagateTaskASAP(this, i, time)
  %
  % We might already have an assigned ASAP with a larger value.
  %
  if ~(this.taskASAP(i) < time), return; end

  this.taskASAP(i) = time;
  time = time + this.taskExecutionTime(i);

  %
  % Shift the data-dependent tasks.
  %
  for j = find(this.application.links(i, :)) % children
    this.propagateTaskASAP(j, time);
  end
end
