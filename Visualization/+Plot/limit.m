function limit(xData, yData, zData)
  if nargin > 0 && ~isempty(xData)
    data = xData(:);
    xlim([ min(data), max(data) ]);
  end

  if nargin > 1 && ~isempty(yData)
    data = yData(:);
    ylim([ min(data), max(data) ]);
  end

  if nargin > 2 && ~isempty(zData)
    data = zData(:);
    zlim([ min(data), max(data) ]);
  end
end
