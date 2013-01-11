function P = barymatp(y,Nx,dom,map,lr)
% BARYMATP Piecewise Barycentric Matrix
%  BARYMATP(NY,NX,DOM) returns a numel(Y) by sum(NX) matrix which projects 
%  data from NX(j) Chebyshev points of the 2nd-kind on the intervals 
%  [DOM(j:j+1)] to the points Y in [DOM([1 end])].
%
%  Y and NX should be vectors. DOM maybe be a vector or a domain.
%
%  BARYMATP(NY,NX,DOM,MAP) is the same, but for mapped Chebyshev grids, 
%  with the map (or maps) given in MAP.
%
%  BARYMATP(NY,NX,DOM,MAP,LR) where LR is 'left' or 'right' chooses left
%  or right sided evaluation when one or more of the Y(k) are one of the
%  breakpoints in DOM. If LR is not given, and Y(k) is, say, DOM(j), then
%  the average of the evaluation using points in DOM(j-1:j) and DOM(j:j+1)
%  is used.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(dom,'domain'), dom = dom.endsandbreaks; end
if isempty(dom), dom = [-1 1]; end
if nargin < 5, lr = []; end

numints = numel(dom)-1;
if numints > 1
    if numel(Nx) < numints,   Nx = repmat(Nx,numints,1);   end
    csNx = [0 ; cumsum(Nx(:))]; 
else
    csNx = 0;
end
Ny = numel(y);

% Construct the Chebyshev points
x = chebpts(Nx,dom,2); x = sort(x);

% Check the map
if nargin > 3 && ~isempty(map)
%     map = mapcheck(map,dom,1);
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
        x(iix) = mapk.for(chebpts(Nx(k),[-1 1],2));
    end
end

% The non-piecewise case simply calls barymat.m
if numints == 1
    P = zeros(numel(y),numel(x));
    idx = find(min(x)<=y & y<=max(x));
    P(idx,:) = barymat(y(idx),x);
    return
end

P = zeros(Ny,numel(x));               % initialise P

% Construct the global matrix
if isempty(lr)
    
    % Standard case
    s = zeros(Ny,1);
    for k = 1:numel(Nx)                         % Loop over blocks.
        iix = csNx(k)+(1:Nx(k));                % x indices of this block.
        iiy = find(min(x(iix))<=y & y<=max(x(iix)));
        P(iiy,iix) = barymat(y(iiy),x(iix));
        s(iiy) = s(iiy)+1;
    %     P(iiy,iix) = barymat(y(iiy),x(iix));    % Local barymat on each block.
    end

    for k = 1:Ny % average out values which appear on either side
        P(k,:) = P(k,:)/s(k);
    end
    
else
    
    if strcmp(lr,'left')
    % Left evaluation
        for j = 1:numel(y) % Align y with x if it's really close
            idx = find(abs(x-y(j)) < 1e-14*(x(end)-x(1)),1,'first');
            if ~isempty(idx), y(j) = x(idx); end
        end
        for k = 1:numel(Nx)                         % Loop over blocks.
            iix = csNx(k)+(1:Nx(k));                % x indices of this block.
            iiy = find(min(x(iix))<y & y<=max(x(iix))+2*eps);
%             iiy = find(min(x(iix))<y & y<=max(x(iix))+2*eps);
%             iiy(y(iiy) > x(idx(iiy))) = []
            P(iiy,iix) = barymat(y(iiy),x(iix));
        end
    else

    % Right evaluation
        for j = 1:numel(y) % Align y with x if it's really close
            idx = find(abs(x-y(j)) < 1e-14*(x(end)-x(1)),1,'last');
            if ~isempty(idx), y(j) = x(idx); end
        end
        for k = 1:numel(Nx)                         % Loop over blocks.
            iix = csNx(k)+(1:Nx(k));                % x indices of this block.
            iiy = find(min(x(iix))<=y+2*eps & y<max(x(iix)));
            P(iiy,iix) = barymat(y(iiy),x(iix));
        end
        
    end
    
end
    


   