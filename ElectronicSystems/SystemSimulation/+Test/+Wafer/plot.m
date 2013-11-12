setup;

wafer = Wafer('floorplan', File.join('Assets', '002.flp'), ...
  'columnCount', 20, 'rowCount', 20);
plot(wafer);
