%% Load a platform and an application.
%
[ platform, application ] = parseTGFF( ...
  File.join(File.trace, 'Assets', '002_020.tgff'));

display(platform);
display(application);

%% Construct a schedule.
%
schedule = Schedule.Dense(platform, application);

display(schedule);
plot(schedule);