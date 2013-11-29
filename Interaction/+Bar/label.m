function label(h)
  X = get(h, 'XData');
  Y = get(h, 'YData');
  arrayfun(@(x, y) text(x, y + 0.2, num2str(y), 'Color', 'r'), X, Y);
  set(gca, 'YTick', NaN);
end
