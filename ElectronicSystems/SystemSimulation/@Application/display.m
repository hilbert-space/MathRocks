function display(this)
  taskCount = length(this);

  fprintf('Application:\n');
  fprintf('  Number of tasks: %d\n', taskCount);

  fprintf('  Data dependencies:\n');
  fprintf('    %4s ( %4s ) -> [ %s ]\n', 'id', 'type', 'children');

  for i = 1:taskCount
    task = this.tasks{i};
    fprintf('    %4d ( %4d ) -> [ ', task.id, task.type);
    for j = 1:length(task.children)
      child = task.children{j};
      if j > 1, fprintf(', '); end
      fprintf('%d', child.id);
    end
    fprintf(' ]\n');
  end
end
