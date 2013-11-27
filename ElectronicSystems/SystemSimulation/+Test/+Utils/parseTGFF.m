%% Load a platform and an application.
%
[ platform, application ] = Utils.parseTGFF( ...
  File.join('Assets', '002_040.tgff'));

display(platform);
display(application);

%% Construct a schedule.
%
schedule = Schedule.Dense('platform', platform, 'application', application);

display(schedule);
plot(schedule);