classdef Task < handle
  properties (SetAccess = 'private')
    id
    type

    isLeaf
    isRoot

    parents
    children
  end

  methods
    function this = Task(id, type)
      this.id = id;
      this.type = type;

      this.isLeaf = true;
      this.isRoot = true;

      this.parents = {};
      this.children = {};
    end

    function addParent(this, parent)
      this.parents{end + 1} = parent;
      this.isRoot = false;
    end

    function addChild(this, child)
      this.children{end + 1} = child;
      this.isLeaf = false;
    end

    function ids = getParents(this)
      count = length(this.parents);
      ids = zeros(1, count);
      for i = 1:count
        ids(i) = this.parents{i}.id;
      end
    end

    function ids = getChildren(this)
      count = length(this.children);
      ids = zeros(1, count);
      for i = 1:count
        ids(i) = this.children{i}.id;
      end
    end
  end
end
