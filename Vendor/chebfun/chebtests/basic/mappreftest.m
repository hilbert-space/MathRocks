function pass = mappreftest
% Tests the mappref options by getting and setting them
% to their default values.

% Pedro Gonnet, January 2011

% check all the settings, do a 'factory' last.
options = { 'name' , 'adapt' , 'par' , 'adaptinf' , 'parinf' };
for i=1:length(options)
    mappref( options{i} , mappref( options{i} ) );
end;
mappref('factory');

% if we made it here, all is well
pass = 1;
