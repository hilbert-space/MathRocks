function limit(xData, yData, zData)
  data = xData(:);
  xlim([ min(data), max(data) ]);

  if nargin > 1
    data = yData(:);
    ylim([ min(data), max(data) ]);
  end

  if nargin > 2
    data = zData(:);
    zlim([ min(data), max(data) ]);
  end
end
