function pass = chebfunpreftest
% Tests the chebfunpref options by getting and setting them
% to their default values.

% Pedro Gonnet, January 2011

% check all the settings, do a 'factory' last.
options = { 'splitting', 'minsamples', 'maxdegree', 'maxlength', 'splitdegree', 'resampling', 'domain', 'eps', 'sampletest', 'blowup', 'chebkind', 'extrapolate' , 'plot_numpts' , 'polishroots' , 'ADdepth' };
for i=1:length(options)
    chebfunpref( options{i} , chebfunpref( options{i} ) );
end;
chebfunpref('factory');

% if we made it here, all is well
pass = 1;
