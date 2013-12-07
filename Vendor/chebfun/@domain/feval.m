function E = feval(d,s,lr)
% FEVAL  Evaluation functional.
% E = FEVAL(D,S) returns a linop representing the functional of evaluation
% of a chebfun at the points in vector S. If f is a chebfun also defined on
% the domain D, then E*f will return a length(S)-by-1 vector equal to 
% f(S(:)).
%
% Example:
%
%  E = feval(domain(-1,2),[-1;0;2]);  % evaluate at endpoints and one other
%  format short
%  E(5)   % note first and last rows are like the identity
%    ans =
%       1.0000         0         0         0         0
%      -0.1728    0.6166    0.6914   -0.2215    0.0864
%            0         0         0         0    1.0000
%
%  f = chebfun(@(x) cos(x)./(1+x.^2),[-1 2]); 
%  format long, [f([-1;0;2]), E*f]
%    ans =
%       0.270151152934070   0.270151152934070
%       1.000000000000000   1.000000000000000
%      -0.083229367309428  -0.083229367309428
%
% See also linop, chebfun/feval.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin > 2
    if ~any(strcmpi(lr,{'left','right',''}));
        if ischar(lr)
            error('CHEBFUN:feval:leftrightchar',...
                'Unknown input argument "%s".',lr);
        else
            error('CHEBFUN:feval:leftright','Unknown input argument.');
        end
    end
else
    lr = [];
end


if isempty(lr)
    E = linop(@(n) mat(d,s,lr,n), @(u) feval(u,s(:)),d);
    E.isdiag = 1;
else
    E = linop(@(n) mat(d,s,lr,n), @(u) feval(u,s(:),lr), d);
end

end

function P = mat(d,s,lr,n)
    [n map breaks numints] = tidyInputs(n,d,mfilename); 

    a = d.ends(1);  b = d.ends(end);
    x = 2*(s(:)-a)/(b-a) - 1;

    % If n == 1, interpolation is easy!!
    if all(n == 1)
        if numints == 1
            P = ones(length(x),1);
        else
            P = zeros(length(x),numints);
            for k = 1:numel(x)
                P(k,:) = x(k) >= breaks(1:end-1) & x(k) <= breaks(2:end);
                P(k,:) = P(k,:)/sum(P(k,:));
            end
        end   
        return
    elseif any(n == 1)
        error('CHEBFUN:domain:feval:n1',...
            'Expansion with n = 1 is not supported.')
    end

    if isempty(map) && isempty(breaks)
        % Standard case
        P = barymat(x,chebpts(n));
    elseif isempty(breaks)
        % Map / no breaks
        if isstruct(map), map = map.for; end
        P = barymat(map(x),map(chebpts(n)));
    elseif isempty(map)
        % Breaks / no map
        P = barymatp(s,n,breaks,[],lr);
    else
        % Breaks and maps
        P = barymatp(s,n,breaks,map,lr);
    end   
end