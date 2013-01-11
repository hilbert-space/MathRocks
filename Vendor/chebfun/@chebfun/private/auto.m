function [funs,ends,scl] = auto(op,ends,scl,pref)
%AUTO Generates funs in a chebfun construction
% [FUNS,ENDS,SCL] = AUTO(OP,ENDS,SCL,PREF)
% AUTO generates a vector of FUNS used to construct a chebfun
% representation of the function handle OP. 
%
% The input vector ENDS must initially consist of two values and 
% corresponds to the global interval [a,b]. The ouput vector ends may 
% contain adional breakpoints if the splitting mode is on. 
%
% SCL is a structure with two fields: SCL.H and SCL.V corresponding to 
% the horizonatal and veritcal global scales. This vector is update 
% within AUTO and is returned as output. 
% 
% PREF is the chebfun preference structure (see chebfunpref).
%
% Note: this function is used in ctor_adapt.m

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
 
% Initial setup.
htol = 1e-14*scl.h;
lenf = 0;

% ----------------------------SPLITTING OFF-------------------------------

% In off mode, seek only one piece with length no greater than maxdegree (default is 2^16)
if ~pref.splitting
     maxn = pref.maxdegree+1;
     [funs,hpy,scl] = getfun(op,ends,pref,scl);
     if ~hpy
        warning('CHEBFUN:auto',['Function not resolved, using ' int2str(maxn) ...
            ' pts. Have you tried ''splitting on''?']);
     end
     return;
end

% ------------------------------------------------------------------------

% ----------------------------SPLITTING ON--------------------------------

pref.extrapolate = true;
% We extrapolate when splitting so that we can construct functions like
% chebfun(@sign,[-1 1]), which otherwise would not be happy at x = 0.

if isfield(pref,'exps'), exps = pref.exps; end

% Try to get one smooth piece for the entire interval before splitting interval
[funs,hpy,scl] = getfun(op,ends,pref,scl);    
sad = ~hpy; 

% MAIN LOOP
% If the above didn't work, enter main loop and start splitting 
% (at least one breakpoint will be introduced).
while any(sad)       
    % If a fun is sad in a subinterval, split this subinterval.
    i = find(sad,1,'first');
    a = ends(i); b = ends(i+1);
    oldfunlength = funs(i).n;
    
    % Look for an edge between [a,b].
    if ~isinf(norm([a,b],inf))
        ex = funs(i).exps;
        if any(ex)            
            edge = detectedge(@(x) op(x)./(x-a).^ex(1)./(b-x).^ex(2),a,b,scl.h,scl.v, @(x) 0.*x+1,pref.blowup);        
        else
            edge = detectedge(op,a,b,scl.h,scl.v, @(x) 0.*x+1,pref.blowup);
        end
 
        if isempty(edge)        % No edge found, split interval at the middle point
            edge = (b+a)/2;
        elseif (edge-a) <= htol % Edge is close to the left boundary, assume it is at x=a
            edge = a+(b-a)/100; % Split interval closer to the left boundary
        elseif (b-edge) <= htol % Edge is close to the right boundary, assume it is at x=b
            edge = b-(b-a)/100; % Split interval closer to the right boundary
        end

    else
        
        % Unbounded case: must use map!
         mapfor = funs(i).map.for; mapder = funs(i).map.der;
         edge = detectedge(@(x) op(mapfor(x)),-1+scl.h*eps,1-scl.h*eps,scl.h,scl.v,mapder,pref.blowup);
         if isempty(edge)
             edge = mapfor(0);      % No edge found, split interval at the middle point
         elseif (edge+1) <= htol    % Edge is close to the left boundary, assume it is at x=a
            edge = mapfor(-1+1/50); % Split interval closer to the left boundary
         elseif (1-edge) <= htol    % Edge is close to the right boundary, assume it is at x=b
            edge = mapfor(1-1/50);  % Split interval closer to the right boundary
         else
             edge = mapfor(edge);
         end
    end
        
    % update horizontal scale!
    scl.h = max(scl.h, abs(edge));
    
    % Try to obtain happy funs on each new subinterval.
    % ------------------------------------

    % Construct child funs
    blank = 0;
    if pref.blowup, blank = NaN; end             % Only looks for exps if blowup is on
    %  left
    if isfield(pref,'exps')                      % exps were passed to the constructor 
        if i == 1, pref.exps = [exps(1), blank]; % We should keep these at the ends.
        else pref.exps = [blank blank]; end      % But not if an interior split.
    end
    [child1, hpy1, scl] = getfun(op, [a, edge], pref, scl);
    %  right
    if isfield(pref,'exps')                      % As above
        if i+1 == length(ends), pref.exps = [blank, exps(2)];
        else pref.exps = [blank blank]; end  
    end
    [child2, hpy2, scl] = getfun(op, [edge, b], pref, scl);
    
    % Insert to existing funs
    funs = [funs(1:i-1) child1 child2 funs(i+1:end)];
    ends = [ends(1:i) edge ends(i+1:end)];
    
    % Check for happiness
    sad  = [sad(1:i-1) not(hpy1) not(hpy2) sad(i+1:end)];

    %-------- Stop? check length --------
    lenf = lenf - oldfunlength + child1.n + child2.n;
    if ~lenf
        for i = 1:numel(funs), lenf = lenf+funs(i).n; end
    end
        
    if lenf > pref.maxlength+1;
        warning('CHEBFUN:auto',['Chebfun representation may not be accurate:' ...
                'using ' int2str(lenf) ' points'])
        return
    end
    % ----------------------------------------
end
