function P = barymatp12(Ny,Nx,dom,map)
% BARYMATP12 Piecewise Barycentric Matrix from 2nd- to 1st-kind points.
%  BARYMATP12(NY,NX,DOM) returns a sum(NY) by sum(NX) matrix which projects 
%  data from NX(j) Chebyshev points of the 2nd-kind on the intervals 
%  [DOM(j:j+1)] to NY(k) Chebyshev poionts of 1st-kind on the same interval
%
%  NY and NX should be vectors. DOM maybe be a vector or a domain.
%
%  BARYMATP12(NY,NX,DOM,MAP) is the same, but for mapped Chebyshev grids, 
%  with the map (or maps) given in MAP.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(dom,'domain'), dom = dom.endsandbreaks; end
if isempty(dom), dom = [-1 1]; end

numints = numel(dom)-1;
if numints > 1
    if numel(Nx) < numints,   Nx = repmat(Nx,numints,1);   end
    if numel(Ny) < numints,   Ny = repmat(Ny,numints,1);   end
    csNx = [0 ; cumsum(Nx(:))]; csNy = [0 ; cumsum(Ny(:))]; 
else
    csNx = 0; csNy = 0;
end

% Construct the Chebyshev points
x = chebpts(Nx,dom,2);    
y = chebpts(Ny,dom,1);

% Check the map
if nargin > 3
    map = mapcheck(map,dom,1);
else
    map = [];
end

if ~isempty(map)
    % Map the points.
    for k = 1:numints
        if iscell(map)
            mapk = map{k};
        elseif numel(map) == 1
            mapk = map;
        else
            mapk = map(k);
        end
        if any(strcmp(mapk.name,{'unbounded','linear'})), continue, end
        iix = csNx(k)+(1:Nx(k));
        x(iix) = mapk.for(chebpts(Nx));
        iiy = csNy(k)+(1:Ny(k));
        y(iiy) = mapk.for(chebpts(Ny,[-1 1],1));
    end
end

% The non-piecewise case simply calls barymat.m
if numints == 1
    P = barymat(y,x);
    return
end

% Construct the global matrix
P = zeros(sum(Ny),sum(Nx));                 % Initialise P.
for k = 1:numel(Nx)                         % Loop over blocks.
    iix = csNx(k)+(1:Nx(k));                % x indices of this block.
    iiy = csNy(k)+(1:Ny(k));                % y indicies.
    P(iiy,iix) = barymat(y(iiy),x(iix));    % Local barymat on each block.
end