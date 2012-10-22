function display(this)
  options = Options( ...
    'Input dimension', this.inputDimension, ...
    'Output dimension', this.outputDimension, ...
    'Order', this.order, ...
    'Nodes', this.nodeCount, ...
    'Interpolants', length(this.interpolants));
  display(options, 'High-dimensional model representation');
end