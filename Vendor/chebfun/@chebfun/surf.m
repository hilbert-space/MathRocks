function varargout = surf(u,varargin)
%SURF Waterfall plot for quasimatrices.
%
%  SURF(U) or SURF(U,T) where LENGTH(T) = MIN(SIZE(U))
%
%  SURF(U,'NUMPTS',N) or SURF(U,T,'NUMPTS',N) changes the number of points
%  used in the mesh. (The default is 201).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

numpts = 201;

trans = u(:,1).trans;
if trans
    u = u.';
end
n = min(size(u,2));
t = 1:n;

if nargin > 1 && isnumeric(varargin{1}) && length(varargin{1}) == size(u,2)
    t = varargin{1}; t = t(:).';
    varargin = {varargin{2:end}};
end

if numel(varargin) > 1 && strcmpi(varargin{1},'numpts')
    numpts = varargin{2};
    varargin(1:2) = [];
end

if length(t)~=n
    error('CHEBFUN:surf:szet', ...
        'Length of T should equal the number of quasimatrices in U');
end

if ~isreal(u) || ~all(isreal(t))
    warning('CHEBFUN:surf:imaginary',...
        'Imaginary parts of complex T and/or U arguments ignored');
    u = real(u); t = real(t);
end

% get the data
data = plotdata([],u,[],numpts);
uu = data{2:end};
xx = repmat(data{1},1,n);
tt = repmat(t,length(xx(:,1)),1);

% mask the NaNs
mm = find(isnan(uu));
uu(mm) = .5*(uu(mm+1)+uu(mm-1));

% plot the surface
if ~trans
    h = surf(xx.',tt.',uu.',varargin{:});
else
    h = surf(xx.',tt.',uu,varargin{:});
end

if nargout > 0
    varargout{1} = h;
end