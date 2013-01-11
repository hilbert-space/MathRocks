function varargout = waterfall(varargin)
% WATERFALL Waterfall plot for quasimatrices.
%
%  WATERFALL(U), or WATERFALL(U,T) where LENGTH(T) = MIN(SIZE(U)), plots a
%  "waterall" plot of a quasimatrix. Unlike the standard Matlab waterfall, 
%  chebfun/waterfall does not fill in the column planes with opaque
%  whitespace or connect edges to zero. This can be enabled if required via
%  WATERFALL(U,'fill') or WATERFALL(U,T,'fill').
%
%  Additional plotting options can also be passed, for example
%   WATERFALL(U,T,'linewidth',2).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% numpts = chebfunpref('plot_numpts');

% Defaults
numpts = 0; numptsmax = inf; numptsmin = 200;
simple = true;

% First input might be a figure handle
[cax,varargin] = axescheck(varargin{:});
if ~isempty(cax)
    axes(cax); %#ok<MAXES>
end

% First input is now the chebfun
u = varargin{1};
varargin(1) = [];

k = 1;
while k <= numel(varargin)
    if strcmpi(varargin{k},'numpts')
        numpts = varargin{k+1};
        varargin(k:k+1) = [];
    elseif strcmpi(varargin{k},'simple')
        varargin(k) = [];
        simple = true;
    elseif strcmpi(varargin{k},'fill')
        varargin(k) = [];
        simple = false;        
    else
        k = k+1;
    end
end
nargin = length(varargin)+1;

trans = u(:,1).trans;
if trans
    u = u.';
end
n = min(size(u,2));
t = 1:n;

if nargin > 1 && isnumeric(varargin{1}) && length(varargin{1}) == size(u,2)
    t = varargin{1}; t = t(:).';
    varargin(1) = [];
end

if length(t)~=n
    error('CHEBFUN:waterfall:szet', ...
        'Length of T should equal the number of quasimatrices in U');
end

if ~isreal(u) || ~all(isreal(t))
    warning('CHEBFUN:waterfall:imaginary',...
        'Imaginary parts of complex T and/or U arguments ignored');
    u = real(u); t = real(t);
end    

if simple, 
    if numpts == 0
        numpts = max(chebfunpref('plot_numpts')/10,10);
    end
%     varargin = [varargin, {'numpts',numpts}]; 
%     x = chebfun('x',domain(u));
%     ish = ishold; h = {};
%     if u(1).trans, u = u.'; end
%     for k = 1:numel(u)
%         tk = t(k) + 0*x;
%         h{k} = plot3(x,tk,u(:,k),varargin{:}); hold on
%     end
%     if ~ish, hold off, end
%     if nargout > 0, varargout{1} = h; end
% %     return
end

% Sort out number of points to use in plot
if numpts == 0
    for k = 1:numel(u)
        numpts = max(numpts,length(u(k)));
    end
    numpts = max(min(numpts,numptsmax),numptsmin);
end
numpts = ceil(numpts);

% get the data
[data ignored data3] = plotdata([],u,[],numpts);
uu = data{2:end};
xx = repmat(data{1},1,n);
tt = repmat(t,length(xx(:,1)),1);

% mask the NaNs
mm = find(isnan(uu));
uu(mm) = uu(mm+1);
uu(1) = uu(1)+eps;

if min(size(uu)) == 1
    xx = [xx xx]; tt = [tt tt]; uu = [uu uu]; t = [1 2];
end

if simple
    ish = ishold;
    mesh(xx.',tt.',uu.','edgecolor','none','facealpha',.75); hold on
    % Intersperse with NaNs
    xx = repmat(xx,1,4);
    mid = repmat((t(1:end-1)+t(2:end))/2,size(tt,1),1);
    tt = reshape([tt ; tt+eps ; [mid NaN*tt(:,end)] ; [tt(:,2:end)-eps NaN*tt(:,end)]],size(xx));
    uu = reshape([uu ; uu ; NaN*uu ; [uu(:,2:end) uu(:,end)]],size(xx));
    mesh(xx.',tt.',uu.',varargin{:});
    if ~ish, hold off; end
end

% plot the waterfall
if ~simple
    h = waterfall(xx.',tt.',uu.',varargin{:});
end

% hide the jumps
if ~trans
    x = []; y = []; z = [];
    for k = 1:2:2*n
        x = [x ; data3{k}];
        y = [y ; t((k+1)/2)*ones(length(data3{k}),1)];
        z = [z ; data3{k+1}];
    end
    if ~all(isnan(z))
        x([1 end]) = [];
        y([1 end]) = [];
        z([1 end]) = [];
        ish = ishold;    hold on
        plot3(x,y,z,'w');
        if ~ish, hold off; end
    end
end 

u = reshape(uu,numel(uu),1);
umin = min(u); umax = max(u);
if umin - umax == 0
    zl = get(gca,'zlim');
    if abs(diff(zl)) < 1e-6
        set(gca,'zlim',umin+1e-2*[-1 1]);
    end
end

if nargout > 0
    varargout{1} = h;
end

