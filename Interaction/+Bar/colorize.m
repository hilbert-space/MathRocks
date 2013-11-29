function colorize(h)
  for i = 1:length(h)
    set(h(i), 'FaceColor', Color.pick(i));
  end
end
