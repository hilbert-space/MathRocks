function varargout = chebpolyplot(u,varargin)
% CHEBPOLYPLOT    Display Chebyshev coefficients graphically.
%
% CHEBPOLYPLOT(U) plots the Chebyshev coefficients of a chebfun U 
% on a semilogy scale. 
%
% If U is a quasimatrix, the coefficients of the first fun in each row 
% (or column) are plotted. CHEBPOLYPLOT(U,K) plots only the coefficients 
% of the row indexed by the vector K. If U is a single chebfun but is 
% composed of more than one fun, then CHEBPOLYPLOT(U,K) plots only the 
% coefficients of the funs indexed by  K.
%
% H = CHEBPOLYPLOT(U) returns a handle H to the figure.
%
% CHEBPOLYPLOT(U,S) and CHEBPOLYPLOT(U,K,S) allow further plotting 
% options, such as linestyle, linecolor, etc. If K is a vector, then
% use CHEBPOLYPLOT(U,K,'.r'), etc to alter plot styles for all of the 
% funs given by K. If S contains a string 'LOGLOG', the coefficients
% will be displayed on a log-log scale.
%
% Example
%     u = chebfun({@sin @cos @tan @cot},[-2,-1,0,1,2]);
%     chebpolyplot(u,'--ok');
%
% See also chebfun/chebpoly, plot

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

k = 0;                      % plot all funs by default
ll = false;                 % default to semilogy plot

% check inputs
if nargin > 1
    if isnumeric(varargin{1}), 
        k = varargin{1};
        varargin(1) = [];
    end
    for j = 1:length(varargin)
        if strcmpi(varargin{j},'loglog')
            ll = true; 
            varargin(j) = [];
            break
        end
    end
end

quasi = false;
if numel(u) > 1, quasi = true; end

if u(1).trans, u = u.'; end

if quasi
    if k == 0, k = 1:numel(u); end
    if any(k > numel(u))
        error('CHEBFUN:chebpolyplot:quasi_oob', 'input chebfun has only %d rows', numel(u));
    end
else
    if k == 0, k = 1:u.nfuns(1); end
    if any(k > u.nfuns)
        error('CHEBFUN:chebpolyplot:funs_oob', 'input chebfun has only %d pieces', u.nfuns);
    end
end

UK = {};
for j = k
    if quasi,
        uk = chebpoly(u(:,j),1);    % coefficients of kth row
    else
        uk = chebpoly(u,j);         % coefficients of kth fun
    end
    uk = abs(uk(end:-1:1));         % flip
    uk(~uk) = eps*max(uk);          % remove zeros for LNT
    nk = length(uk)-1;
    
    if nk==0, plotopts = {'x'};     % If only one coeff, plot an x
    else      plotopts = varargin; end
    
    UK = [UK, {0:nk, uk}, plotopts]; % store
end

if ~ll
    h = semilogy(UK{:});            % semilogy plot
else
    h = loglog(UK{:});              % loglog plot
end
    
if j > 1
    legend(int2str(k.'))
end

% output handle
if nargout ~=0
    varargout = {h};
end
