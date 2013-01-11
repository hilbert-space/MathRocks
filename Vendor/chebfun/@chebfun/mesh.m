function varargout = mesh(varargin)
% MESH   Mesh plot for quasimatrices.
%
% MESH(U) or MESH(U,T), where LENGTH(T) = MIN(SIZE(U)), draws a 
% wireframe mesh with color determined by U so color is proportional to 
% surface height.
%
% MESH(U,'NUMPTS',N) or MESH(U,T,'NUMPTS',N) changes the number of points
% used in the mesh. (The default is 201).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Defaults
numpts = 201;

% First input might be a figure handle
[cax,varargin] = axescheck(varargin{:});
if ~isempty(cax)
    axes(cax); %#ok<MAXES>
end

% First input is now the chebfun
u = varargin{1};
varargin(1) = [];

trans = u(:,1).trans;
if trans
    u = u.';
end
n = min(size(u,2));
t = 1:n;

if ~isempty(varargin) && isnumeric(varargin{1}) && length(varargin{1}) == size(u,2)
    t = varargin{1}; t = t(:).';
    varargin(1) = [];
end

if numel(varargin) > 1 && strcmpi(varargin{1},'numpts')
    numpts = varargin{2};
    varargin(1:2) = [];
end

if length(t)~=n
    error('CHEBFUN:mesh:szet', ...
        'Length of T should equal the number of quasimatrices in U');
end

if ~isreal(u) || ~all(isreal(t))
    warning('CHEBFUN:mesh:imaginary',...
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

% plot the mesh
if ~trans
    h = mesh(xx.',tt.',uu.',varargin{:});
else
    h = mesh(xx.',tt.',uu,varargin{:});
end

if nargout > 0
    varargout{1} = h;
end