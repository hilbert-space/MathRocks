function pref = chebopdefaults
% Default chebfunprefs for chebops

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

pref = chebfunpref;
% pref.splitting = false;
pref.sampletest = false;
pref.resampling = true;
pref.exps = [0 0];
pref.blowup = -1;
pref.vecwarn = 0;
pref.vectorcheck = 0;
pref.chebkind = 2;

