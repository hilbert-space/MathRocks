function display(this)
  fprintf('Schedule:\n');
  fprintf('  %4s %8s %8s %8s %8s %8s\n', ...
    'id', 'priority', 'mapping', 'order', 'start', 'duration');

  for i = 1:length(this.application)
    fprintf('  %4d %8.3f %8d %8d %8.3f %8.3f\n', ...
      i, this.priority(i), this.mapping(i), this.order(i), ...
      this.startTime(i), this.executionTime(i));
  end
end
