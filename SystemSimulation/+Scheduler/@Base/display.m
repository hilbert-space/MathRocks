function display(this, output)
  output = this.decode(output);

  duration = max(output.startTime + output.executionTime);

  fprintf('Schedule:\n');
  fprintf('  Duration: %.2f s\n', duration);
  fprintf('  %4s %8s %8s %8s %8s %8s\n', ...
    'id', 'priority', 'mapping', 'order', 'start', 'duration');

  for i = 1:length(this.application)
    fprintf('  %4d %8.3f %8d %8d %8.3f %8.3f\n', i, ...
      output.priority(i), output.mapping(i), output.order(i), ...
      output.startTime(i), output.executionTime(i));
  end
end
