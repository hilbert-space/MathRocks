function display(r)
% DISPLAY Pretty-print domain to the command output.
%
% See also CHEBOP/CHAR.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

loose = ~isequal(get(0,'FormatSpacing'),'compact');
if loose, fprintf('\n'), end
disp([inputname(1) ' = domain']);
if loose, fprintf('\n'), end
fprintf( [char(r) '\n'] )
if loose, fprintf('\n'), end