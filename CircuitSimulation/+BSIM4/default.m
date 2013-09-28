function card = default(card)
  if ~isfield(card, 'xw'), card.xw = 0; end
  if ~isfield(card, 'min'), card.min = 0; end
end
