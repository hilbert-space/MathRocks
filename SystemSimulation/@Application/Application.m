classdef Application < handle
  properties (SetAccess = 'private')
    tasks
  end

  properties (Access = 'private')
    taskMap
  end

  methods
    function this = Application()
      this.tasks = {};
      this.taskMap = containers.Map();
    end

    function count = length(this)
      count = length(this.tasks);
    end

    function varargout = subsref(this, S)
      switch S(1).type
      case '{}'
        o = this.tasks;
      case '()'
        o = this.tasks;
      otherwise
        o = this;
      end
      varargout = cell(1, nargout);
      if nargout == 0
        builtin('subsref', o, S);
      else
        [ varargout{:} ] = builtin('subsref', o, S);
      end
    end

    function task = addTask(this, name, type)
      id = length(this) + 1;
      task = Task(id, type);
      this.tasks{end + 1} = task;
      this.taskMap(name) = task;
    end

    function addLink(this, parent, child)
      parent = this.taskMap(parent);
      child = this.taskMap(child);
      parent.addChild(child);
      child.addParent(parent);
    end

    function ids = getRoots(this)
      count = length(this.tasks);
      ids = zeros(1, count);
      for i = 1:count
        if this.tasks{i}.isRoot, ids(this.tasks{i}.id) = 1; end
      end
      ids = find(ids);
    end

    function ids = getLeaves(this)
      count = length(this.tasks);
      ids = zeros(1, count);
      for i = 1:count
        if this.tasks{i}.isLeaf, ids(this.tasks{i}.id) = 1; end
      end
      ids = find(ids);
    end
  end
end
