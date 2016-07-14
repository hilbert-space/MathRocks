classdef Application < handle
  properties (SetAccess = 'private')
    tasks

    roots
    leaves

    links
  end

  properties (Access = 'private')
    names
  end

  methods
    function this = Application()
      this.tasks = {};

      this.names = containers.Map;

      this.roots = [];
      this.leaves = [];

      this.links = uint8([]);
    end

    function count = length(this)
      count = length(this.tasks);
    end

    function task = addTask(this, name, type)
      id = length(this) + 1;

      task = Task(id, type);
      this.tasks{end + 1} = task;

      this.names(name) = task;

      %
      % The task is a new one; therefore, without additional
      % information, it appears to be both a root and a leaf.
      %
      this.roots = uint16([this.roots, id]);
      this.leaves = uint16([this.leaves, id]);

      %
      % Extend the link matrix by one row and one column.
      %
      this.links(id, id) = 0;
    end

    function addLink(this, parentName, childName)
      parent = this.names(parentName);
      child = this.names(childName);

      parent.addChild(child);
      child.addParent(parent);

      %
      % Exclude the parent from the leaves and
      % the child from the roots.
      %
      this.roots(this.roots == child.id) = [];
      this.leaves(this.leaves == parent.id) = [];

      %
      % Keep track of all the links.
      %
      this.links(parent.id, child.id) = 1;
    end
  end
end
