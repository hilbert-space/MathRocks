setup;

wafer = Wafer('floorplan', File.join('+Test', 'Assets', '002.flp'), ...
  'columns', 20, 'rows', 40);
plot(wafer);
