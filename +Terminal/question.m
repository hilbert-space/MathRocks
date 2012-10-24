function output = question(text)
  output = Terminal.request( ...
    'prompt', text, 'type', 'logical', 'default', true);
end
