classdef Application < handle
  properties (SetAccess = 'private')
    tasks

    %
    % We need to maintain the following vectors and maps
    % to gain some computational speed up.
    %

    roots
    leaves

    mapParents
    mapChildren
  end

  properties (Access = 'private')
    mapNames
  end

  methods
    function this = Application()
      this.tasks = {};

      this.mapParents = Map('uint32');
      this.mapChildren = Map('uint32');

      this.mapNames = Map('char');

      this.roots = [];
      this.leaves = [];
    end

    function count = length(this)
      count = length(this.tasks);
    end

    function task = addTask(this, name, type)
      id = length(this) + 1;

      task = Task(id, type);
      this.tasks{end + 1} = task;

      this.mapParents(id) = [];
      this.mapChildren(id) = [];

      this.mapNames(name) = task;

      %
      % The task is a new one; therefore, without additional
      % information, it appears to be both a root and a leaf.
      %
      this.roots = uint16([ this.roots, id ]);
      this.leaves = uint16([ this.leaves, id ]);
    end

    function addLink(this, parentName, childName)
      parent = this.mapNames(parentName);
      child = this.mapNames(childName);

      parent.addChild(child);
      child.addParent(parent);

      this.mapParents(child.id) = ...
        uint16([ this.mapParents(child.id), parent.id ]);
      this.mapChildren(parent.id) = ...
        uint16([ this.mapChildren(parent.id), child.id ]);

      %
      % Exclude the parent from the leaves and
      % the child from the roots.
      %
      this.roots(this.roots == child.id) = [];
      this.leaves(this.leaves == parent.id) = [];
    end
  end
end
