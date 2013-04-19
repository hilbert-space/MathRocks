%% Load a platform and an application.
%
[ platform, application ] = Utils.parseTGFF( ...
  File.join('+Test', 'Assets', '002_020.tgff'));

display(platform);
display(application);

%% Construct a schedule.
%
schedule = Schedule.Dense(platform, application);

display(schedule);
plot(schedule);