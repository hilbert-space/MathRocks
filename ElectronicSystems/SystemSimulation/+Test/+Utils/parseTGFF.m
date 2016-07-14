function parseTGFF
  setup;

  [platform, application] = Utils.parseTGFF( ...
    File.join('Assets', '002_040.tgff'));

  display(platform);
  display(application);

  scheduler = Scheduler.Dense( ...
    'platform', platform, 'application', application);

  output = scheduler.compute;

  display(scheduler, output);
  plot(scheduler, output);
end
