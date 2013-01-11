function map = maps(fun,varargin)
% MAPS
%  This function allows you to call the maps which are buried in
%  @fun/private. It will not usually be called directly by the user, 
%  but rather by its sister function maps.m in the trunk.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1 && isempty(fun)
    map = struct('for',[],'inv',[],'der',[],'name',[],'par',[],'inherited',[]);
    return
end

if length(varargin) == 1 && isa(varargin{1},'domain')
% We check for the special case where the input is a domain and if so
% return the default map for that domain.
    d = varargin{1};
    if isempty(d)
        map = struct('for',[],'inv',[],'der',[],'name',[],'par',[],'inherited',[]);
        return
    end
    d = d.endsandbreaks;
    for k = 1:numel(d)-1
        dk = d(k:k+1);
        if ~any(isinf(dk)) % Get default map from mappref 
            map(k) = feval(mappref('name'),[dk mappref('par')]);
        else % Use default unbounded map
            map(k) = maps(fun,'unbounded',dk);
        end
    end
    return
end

    
if length(varargin) == 1,
    varargin = {varargin};
    ends = chebfunpref('domain');
else
    ends = varargin{2};
    if isnumeric(ends) && length(ends) == 1
        if length(varargin) == 3, 
            ends = varargin{3};
            varargin(3) = [];
        else
            ends = chebfunpref('domain');
        end
    else
        varargin(2) = [];
    end
    if isa(ends,'domain')
        ends = ends.ends;
    else
        ends = ends(:).';
    end
end

v1 = varargin{1};
if isstruct(v1)
    mapname = v1.name;
    v1par = v1.par;
    pars = v1par(3:end);
elseif iscell(v1)
    mapname = v1{1};
    if numel(v1) == 2
        pars = v1{2}(:).';
    else
        pars = []; 
    end    
else
    mapname = v1;
    if length(varargin) >= 2
        pars = [varargin{2:end}.'];
    else
        pars = []; 
    end  
end

map = feval(mapname,[ends pars]);
