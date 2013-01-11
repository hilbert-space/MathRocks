function f = update_vscl(f)
% Updates the vertical scale field of a chebfun.
% Goes through funs to find the largest vertical scale and updates the 
% global scale accordingly.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% vscl = 0;
% for k = 1:f.nfuns
%     vscl = max(vscl, get(f.funs(k),'scl.v'));
% end
vscl = max(get(f.funs,'scl.v'));

f.funs = set(f.funs,'scl.v',vscl);
f.scl = vscl;