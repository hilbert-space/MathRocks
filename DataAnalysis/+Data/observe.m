function observe(varargin)
  [ data, options ] = Options.extract(varargin{:});
  assert(length(data) == 1, ...
    'The observation is supported only for one set of data.');
  observe2D(data{1}, options);
end

function observe2D(data, options)
  [ ~, dimension ] = size(data);

  switch options.get('layout', 'tiles')
  case 'joint'
    figure;
    for i = 1:dimension
      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      [ x, one ] = Data.process(x, one, options);

      Data.draw(x, one, options, 'color', Color.pick(i));
    end
  case 'separate'
    for i = 1:dimension
      figure;

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      [ x, one ] = Data.process(x, one, options);

      Data.draw(x, one, options);
    end
  case 'tiles'
    figure;

    for i = 1:dimension
      subplot(1, dimension, i);

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Data.process(x, one, options);

      Data.draw(x, one, options);
    end
  end
end
