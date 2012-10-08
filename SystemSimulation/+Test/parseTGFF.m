%% Load a platform and an application.
%
[ platform, application ] = parseTGFF('002_020.tgff');

%% Construct a schedule.
%
schedule = Schedule.Dense(platform, application)

%% Draw.
%
schedule.draw()

fprintf('Duration: %.4f s\n', duration(schedule));
