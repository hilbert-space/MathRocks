function observe(varargin)
  [ data, options ] = Options.extract(varargin{:});
  assert(length(data) == 1, ...
    'The observation is supported only for one set of data.');
  observe2D(data{1}, options);
end

function observe2D(Data, options)
  [ ~, dimension ] = size(Data);

  figure;

  for i = 1:dimension
    p = subplot(1, dimension, i);

    data = Data(:, i);

    x = constructLinearSpace(data, options);
    [ x, data ] = processData(x, data, options);

    drawData(x, data, options);
  end
end
