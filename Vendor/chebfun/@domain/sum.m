function S = sum(d)
% SUM  Integral functional.
% S = SUM(D) returns a linop representing the integration functional on the
% domain D. 
%
% Example:
%
% S=sum(domain(-1,1));
% S(5) % Clenshaw-Curtis weights
%   ans =
%      6.6667e-002  5.3333e-001  8.0000e-001  5.3333e-001  6.6667e-002
% f = chebfun(@(x) cos(x)./(1+x.^2),[-1 1]); 
% format long, [sum(f) S*f]
%   ans =
%      1.365866063614065   1.365866063614065
%
% See also linop, chebpts, chebfun/sum.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

S = linop(@(n)mat(d,n),@sum,d);
end

function A = mat(d,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(map)
    % No map
    if isempty(breaks), breaks = d.ends([1 end]); end
    [ignored,A] = chebpts(n,breaks);
elseif isempty(breaks) && ~isempty(map)
    % Map / No breaks
    [x,A] = chebpts(n);
    A = A.*map.der(x');
else
    % Breaks and maps
    csn = [0 cumsum(n)];
    A = zeros(1,csn(end));
    if iscell(map) && numel(map) == 1, map = map{1}; end
    mp = map;
    for k = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{k}; end
            if isstruct(map), mp = map(k); end
        end
        ii = csn(k)+(1:n(k));
        [x,Ak] = chebpts(n(k));
        A(1,ii) = Ak.*mp.der(x');
    end
end

end
