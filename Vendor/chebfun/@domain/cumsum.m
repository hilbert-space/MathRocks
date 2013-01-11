function J = cumsum(d,m)
% CUMSUM Indefinite integration operator.
% Q = CUMSUM(D) returns a linop representing indefinite integration (with
% zero endpoint value) on the domain D.
%
% Q = CUMSUM(D,M) returns the linop for M-fold integration.
%
% See also linop, chebfun.cumsum.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(d)
    J = linop;
else
    J = linop( @(n) mat(d,n), @(u) cumsum(u), d, -1 );
    if nargin > 1
        J = mpower(J,m);
    end
end

end

function C = mat(d,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(map) && isempty(breaks)
    % Standard case
    C = .5*cumsummat(n)*length(d);
elseif isempty(breaks)
    % Map / no breaks
    if isstruct(map) && isfield(map,'der') && ~isempty(map.der)
        gp = map.der(chebpts(n));
        if isinf(gp(1)), gp(1) = 1; end
        if isinf(gp(end)), gp(end) = 1; end
        C = cumsummat(n)*diag(gp);
    else
        error('DOMAIN:cumsum:mapder', ...
            'Cumsum requires a map structure for mapped methods.');
    end
elseif isempty(map)
    % Breaks / no map
    csn = [0 cumsum(n)];
    C = zeros(csn(end));
    for k = 1:numints
        ii = csn(k)+(1:n(k));
        C(ii,ii) = .5*cumsummat(n(k))*diff(breaks(k:k+1));
        if k > 1
            C(ii,1:ii(1)-1) = repmat((C(ii(1)-1,1:ii(1)-1)),ii(end)+1-ii(1),1);
        end
    end
else
    % Breaks and maps
    csn = [0 cumsum(n)];
    C = zeros(csn(end));
    if iscell(map) && numel(map) == 1
        map = map{1};
    end
    mp = map;
    for k = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{k}; end
            if isstruct(map), mp = map(k); end
        end
        ii = csn(k)+(1:n(k));
        if isfield(mp,'der') && ~isempty(mp.der)
            C(ii,ii) = cumsummat(n(k))*diag(mp.der(chebpts(n(k))));
        else
            error('DOMAIN:cumsum:mapder', ...
                'Cumsum requires a map structure for mapped methods.');
        end
        if k > 1
            C(ii(1):end,1:ii(1)-1) = repmat((C(ii(1)-1,1:ii(1)-1)),csn(end)+1-ii(1),1);
        end
    end
end
end
