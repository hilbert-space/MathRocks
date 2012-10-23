function output = question(text)
  output = Input.request('prompt', text, 'type', 'logical', 'default', true);
end
