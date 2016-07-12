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
  end
end
