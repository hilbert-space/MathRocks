classdef Bar < handle
  properties (Access = 'private')
    template
    total
    done
    handle
  end

  methods
    function this = Bar(template, total, done)
      if nargin < 3, done = 0; end
      this.template = template;
      this.total = total;
      this.done = done;

      color = Color.pick(randi(10));

      this.handle = waitbar(done / total, ...
        sprintf(this.template, done, total));
      set(findobj(this.handle, 'type', 'patch'), ...
        'edgecolor', color, 'facecolor', color);
    end

    function increase(this)
      this.done = this.done + 1;
      waitbar(this.done / this.total, this.handle, ...
        sprintf(this.template, this.done, this.total));
      if this.done == this.total, close(this); end
    end

    function close(this)
      close(this.handle);
    end
  end
end
