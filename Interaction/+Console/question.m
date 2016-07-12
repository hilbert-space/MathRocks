function output = question(text)
  output = Console.request( ...
    'prompt', text, 'type', 'logical', 'default', true);
end
