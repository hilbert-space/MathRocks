function display(this)
  processorCount = length(this);

  fprintf('Platform:\n');
  fprintf('  Number of processors: %d\n', processorCount);

  fprintf('  Processors:\n');
  fprintf('    %4s ( %5s )\n', 'id', 'types');

  for i = 1:processorCount
    processor = this.processors{i};
    fprintf('    %4d ( %5d )\n', processor.id, processor.typeCount);
  end
end
