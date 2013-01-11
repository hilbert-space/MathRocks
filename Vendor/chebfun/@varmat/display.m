function display(V)
% DISPLAY  Pretty-print a varmat.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

loose = ~isequal(get(0,'FormatSpacing'),'compact');
if loose, disp(' '), end
disp([inputname(1) ' = varmat']);
if loose, disp(' '), end

s = char(V);
disp(s)
if loose, disp(' '), end

end
