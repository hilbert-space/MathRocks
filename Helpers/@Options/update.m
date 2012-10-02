function update(this, varargin)
  i = 1;

  while i <= length(varargin)
    item = varargin{i};

    if isa(item, 'Options')
      names = properties(item);
      for j = 1:length(names)
        if ~isprop(this, names{j}) this.addprop(names{j}); end
        this.(names{j}) = item.(names{j});
      end
      i = i + 1;
    else
      if ~isprop(this, item) this.addprop(item); end
      this.(item) = varargin{i + 1};
      i = i + 2;
    end
  end
end
