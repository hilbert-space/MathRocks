function varargout = chebfun2pref(varargin)
% CHEBFUN2PREF Settings for Chebfun2.
%
% CHEBFUN2PREF, by itself, returns a structure with current preferences as
% fields/values. Use it to find out what preferences are available.
%
% CHEBFUN2PREF(PREFNAME) returns the value corresponding to the preference
% named in the string PREFNAME.
%
% CHEBFUN2PREF(PREFNAME,PREFVAL) sets the preference PREFNAME to the value
% PREFVAL.  S = CHEBFUN2PREF(PREFNAME,PREFVAL) will store the current state of
% chebfunpref to S before changing PREFNAME.
%
% S = CHEBFUN2PREF will return the current preferences in a structure, which 
% may then be used in the form CHEBFUN2PREF(P) to reload them. 
%
% CHEBFUN2PREF creates a persistent variable that stores these preferences.
% CLEAR ALL will not clear preferences, but MUNLOCK CHEBFUNPREF followed by
% CLEAR CHEBFUN2PREF will (quitting Matlab also clears this variable).
%
% CHEBFUN2 PREFERENCES (case sensitive)
%
%  minsample - Minimum number of points used by the constructor. The 
%        constructed chebfun2 might be shorter. Must be of the form 2^n+1. 
%
%  maxslice - Maximum degree taken along one variable. 
%
%  maxrank - Maximum number of pivots taken during the construction
%  process. 
%
%  plot_numpts - Number of points used to plot a chebfun2.
%
%  xdom - Default domain in the x-variable. 
% 
%  ydom - Default domain in the y-variable. 
% 
%  eps - Relative tolerance used in construction and subsequent operations.
%
%  mode - If mode = 1 then everything is kept as continuous objects.  For
%  speed we recommend this is kept to mode = 0. 

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers.
% See http://www.maths.ox.ac.uk/chebfun/chebfun2 for Chebfun2 information.

persistent prefs2 

% First call; set factory values
if isempty(prefs2)
    prefs2 = initPrefs();
    if nargout == 0
        varargout = {prefs2}; return;
    end 
    %mlock % Locks the currently running M-file so that clear functions do not remove it.
          % Use munlock and clear chebfunpref if you edit this file.
end

% % To speedup preference checks, try this first. 
% -----------------------------------------------
if nargin == 1
    try
        varargout{1} = prefs2.(lower(varargin{1}));
        return
    catch
        % Move on to longer process.
    end  
end        
% -----------------------------------------------

% Assign prefs before changes are made.
%if nargout == 0, varargout = {prefs2}; end
if nargin == 0, varargout = {prefs2}; end
if nargout == 1, varargout = {prefs2}; end
% if nargout == 1, varargout = {prefs.(varargin{1})}; end

if nargin == 2
   prefs2.(lower(varargin{1})) = varargin{2}; 
end


end

function prefs = initPrefs()
    prefs.minsample = 9;     % minimum sample is minsample^2;
    prefs.maxslice = 2^17+1; 
    prefs.maxrank = 2048;
    prefs.plot_numpts = 200;  % plot_numpt^2 pts used. 
    prefs.xdom = [-1 1];
    prefs.ydom = [-1 1];
    prefs.eps = 2^-51;        % tolerance to aim for.
    prefs.mode = 0;      % turn chebfun slices off. 
end