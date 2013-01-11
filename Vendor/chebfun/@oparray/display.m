function display(A)
% DISPLAY  Pretty-print an oparray.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

loose = ~isequal(get(0,'FormatSpacing'),'compact');
if loose, disp(' '), end
disp([inputname(1) ' = oparray']);
if loose, disp(' '), end

s = char(A);
disp(s)
if loose, disp(' '), end

end
