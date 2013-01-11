function m = mapcheck(map,dom,flag)
% MAPCHECK  Clean up map structures
%  MAP = MAPCHECK(MAP) checks the input map MAP to ensure it is a proper
%  Chebfun map structure type, i.e., in the form returned by maps(domain).
%
%  MAP = MAPCHECK(MAP,DOM) checks the MAP is appropriate for the domain DOM.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(map), m = map; return; end

if nargin < 3, flag = 0; end

% Parse inputs
if nargin > 1
    if isa(dom,'domain'), dom = dom.endsandbreaks; end
    if numel(dom) == 1
        flag = dom;
        dom = [];
        numints = 1;
    else
        numints = numel(dom)-1;
    end
else
    numints = 1; dom = [];
end

nmaps = numel(map);
if isa(map,'function_handle')
    map = {map};
end

if numints == nmaps
    %continue
elseif numints == 1 && nmaps > 1
    if isempty(dom) 
        numints = nmaps; 
    else
        error('CHEBFUN:mapcheck:nmaps','Too many maps for given domain.');
    end
elseif nmaps == 1 && numints > 1
    map = repmat(map,1,numints);
else
    error('CHEBFUN:mapcheck:incon','Inconsistent maps / domain.');
end

m = maps(fun);
if isstruct(map)
    m = map;
elseif iscell(map)
    for k = 1:numel(map)
        if isstruct(map{k})
            m(k) = map{k};
        elseif isa(map{k},'function_handle')
            m(k).for = map{k};
        end
    end
end

if flag
    strip = true;
    for k = 1:nmaps
        if ~any(strcmp(map(k).name,{'linear','unbounded'}))
            strip = false;
            break
        end
    end
    if strip, m = []; end
end


