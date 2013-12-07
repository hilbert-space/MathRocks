function g = ctor(g , op , ends , varargin )
% CTOR  chebfun2 constructor
% This constructor is basically just a parser and then calls the fun2
% constructor.  At the moment a chebfun2 is made up of just one fun2, but
% this could change in a future release. The command fun2/private/ctor is 
% where every function gets approximated. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% At the moment a Chebfun2 is really just a fun2.

% no ends supplied so use preferences.
pref = chebfun2pref;
if(nargin < 3), ends = [pref.xdom pref.ydom]; end
if( numel(ends) == 2) % go search for the other two.
    if nargin > 3
        if(~isempty(varargin{1}))
            if(length(varargin{1}) == 2) % found it.
                ends = [ ends varargin{1}];
                varargin = [];
            end
        end
    else
        ends = [ends ends]; % fill it in with default in y-direction.
        warning('CHEBFUN2:constructor:domain','Rectangle has four corners, only two were given. Assuming the rectangle is square.');
    end
end

%  If the function g is already a chebfun2 then we don't need to do much. 
if isa(op,'chebfun2')
   rect = op.corners; 
   if isa(ends,'double')
       if (rect(1)<=ends(1) && rect(2)>=ends(2) && rect(3)<=ends(3) && rect(4)>=ends(4))
           if rect == ends
               g = op;
               return;  % nothing to do.
           end
           g = restrict(op,ends);
       else
           error('CHEBFUN2:CONSTRUCTOR','New domain is not a subset of old domain.');
       end
   else
       error('CHEBFUN2:CONSTRUCTOR','Prescribed domain should be a vector of doubles.');
   end
end



% Check that we haven't been given an infinite domain.
if any(isinf(ends))
   error('CHEBFUN2:CTOR:domain','Chebfun2 does not allow infinite domains.');
end
% Check that domain has real corners. 
if any(~isreal(ends))
   error('CHEBFUN2:CTOR:domain','Rectangular domain must be in the real plane.');
end

if any(strcmpi(ends,'vectorize')) || any(strcmpi(ends,'vectorise'))
    if nargin == 4 
        % try and find the ends. 
        g = ctor(g,op,varargin{1},'vectorize'); return; 
    elseif nargin > 4
        g = ctor(g,op,varargin{1},'vectorize',varargin{2:end}); return;
    else
        ends = [pref.xdom pref.ydom]; varargin = {'vectorize'};
    end
end

% If we have been given coefficients. 
if any(strcmpi(ends,'coeffs'))
    g = ctor(g,chebifft(chebifft(op).').',varargin{:});
    return;
end

% If we are given equispaced data and the 'equi' flag, arrange domain input.
if any(strcmpi(ends,'equi'))
    if (nargin < 4) 
        ends = [pref.xdom pref.ydom];
    elseif (length(varargin{1}) == 4)
        ends = varargin{1};
    else
        error('CHEBFUN2:CONSTRUCTOR','Prescribed domain should be a vector of doubles.');        
    end
    varargin = {'equi'};
end

% % If we have been given a rank. 
% if any(strcmpi(ends,'rank'))
%     % varargin should not be empty
%     if isempty(varargin)
%        error('CHEBFUN2:CTOR:INPUTS','Rank should be an integer.'); 
%     end
%     ends = [pref.xdom pref.ydom];  % take default.
%     g = ctor(g,op,ends,'rank',varargin{:});
%     return;
% end

% Check that the ends vector is of length 4 now. 
if numel(ends) == 1
    varargin = {ends};
    ends = [pref.xdom pref.ydom]; 
elseif ( numel(ends) ~= 4 )
    error('CHEBFUN2:CTOR:domain','Rectangle not prescribed by four doubles.');
end

% Check that ends forms a domain. 
if ends(1) >= ends(2) || ends(3) >=ends(4)
    error('CHEBFUN2:CTOR:domain','Cannot form a chebfun2 on an empty domain');
end

if ~isa(op,'fun2')
    % construct a fun2 object
    if isempty( varargin )
        if strcmpi(ends,'coeffs')
            % user has supplied bivariate coefficients, convert to values.
            op = chebifft(chebifft(op).').';temp = fun2(op,ends);
            ends = [pref.xdom pref.ydom];
        else
            temp = fun2(op, ends);
        end
    else
        temp = fun2(op, ends , varargin{:});
    end
else
    temp = op;
    u = [-1 1]; ends = op.map.for(u,u);
end

g.fun2=temp;
g.nfun2=1;
g.corners=ends;
g.scl = temp.scl;
end