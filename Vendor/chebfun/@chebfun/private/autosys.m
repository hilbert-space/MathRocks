function [funs,ends,scl] = autosys(op,ends,pref)
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

if ~iscell(ends), ends = {ends}; end

if nargin < 3, pref = chebfunpref; end

% ----------------------------SPLITTING OFF-------------------------------

% In off mode, seek only one piece with length no greater than maxdegree (default is 2^16)
if ~pref.splitting
     maxn = pref.maxdegree+1;
     
     [funs,hpy,scl] = growsys(op,ends,pref);
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

% Try to get one smooth piece for the entire interval before splitting interval
[funs,hpy,scl] = growsys(op,ends,pref);

syssize = numel(ends);
numints = numel([ends{:}]) - syssize;

oldends = ends;

% MAIN LOOP
% If the above didn't work, enter main loop and start splitting 
% (at least one breakpoint will be introduced).
while ~all(hpy)  
    
    l = 1;
    indx = zeros(numints,2);
    for j = 1:syssize
        for k = 1:numel(ends{j})-1
            indx(l,:) = [j k];
            l = l+1;
        end
    end
    
    ii = find(~hpy);
    for l = ii(end:-1:1);
        jk = indx(l,:); j = jk(1); k = jk(2);
        a = ends{j}(k); b = ends{j}(k+1);
        edge = .5*(a+b);
        if any(isinf([a b])) && isfield(pref,'map')
            % Bisection on unbounded domains is a little trickier.
            edge = pref.map.for(0);
        end
        ends{j} = [ends{j}(1:k) edge ends{j}(k+1:end)];
        numints = numints+1;
    end
    
    [funs,hpy,scl] = growsys(op,ends,pref);   

end

for k = 1:numel(funs)
    if length(funs{k}.ends)>2         
        % Avoid merging at specified breakpoints
        funs{k} = merge(funs{k},find(~ismember(ends{k},oldends{k})),pref); 
    end
end