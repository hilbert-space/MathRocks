function g = ctor(g , opx , opy, ends , varargin )
% CTOR  chebfun2v constructor
% This function calls the chebfun2 constructor once for each non-zero
% component because a chebfun2v is just vector of chebfun2 objects.

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% no ends supplied so use preferences.
pref = chebfun2pref;
threecomponents = 0;

if isa(opx,'chebfun2v') % argument is a chebfun2v so there is nothing to do.
    g = opx;
    return;
end

if nargin <= 4
    varargin = {};
end

% Did the inputs require a chebfun2v of three components?
if nargin > 3
    if ( isa(ends,'function_handle') || isa(ends,'char') || isa(ends,'chebfun2')  || (isa(ends,'double') && (min(size(ends)) > 1 || max(size(ends))==1)))
        opz = ends;  % let's hope the third component is a function.
        threecomponents = 1;
        if nargin > 4
            ends = varargin{1};
            varargin = varargin(2:end); % push everything along one.
        end
    end
end

if nargin < 3
    error('CHEBFUN2v:constructor:inputs','Two arguments are required to construct a chebfun2v.');
end

if (nargin < 4)
    ends = [pref.xdom pref.ydom];
elseif threecomponents && nargin < 5
    ends = [pref.xdom pref.ydom];
end

% Make the first component. 
if ( isa(opx,'function_handle') || isa(opx,'char') || isa(opx,'double') )
    g.xcheb = chebfun2(opx,ends);
elseif(isa(opx,'chebfun2') )
    g.xcheb = opx;
else
    error('CHEBFUN2v:constructor:optype','Chebfun2v cannot be constructed from this object.');
end

% Make the second component. 
if ( isa(opy,'function_handle') || isa(opy,'char') || isa(opx,'double') )
    g.ycheb = chebfun2(opy,ends);
elseif(isa(opy,'chebfun2') )
    g.ycheb = opy;
else
    error('CHEBFUN2v:constructor:optype','Chebfun2v cannot be constructed from this object.');
end

% Make the third component if it exists. 
if threecomponents
    if ( isa(opy,'function_handle') || isa(opy,'char')  || isa(opx,'double') )
        g.zcheb = chebfun2(opz,ends);
    elseif(isa(opy,'chebfun2') )
        g.zcheb = opz;
    else
        error('CHEBFUN2v:constructor:optype','Chebfun2v cannot be constructed from this object.');
    end
else
    g.zcheb = chebfun2; 
end

g.isTransposed = 0;
