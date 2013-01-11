function varargout = chebellipseplot(u,varargin)
% CHEBELLIPSEPLOT    Plot the Bernstein (aka Chebyshev) ellipses.
% 
% CHEBELLIPSEPLOT(U,EPS) plots ellipses in the complex plane for each 
% piecewise part of U, with foci at the U.ends and semi-minor and major 
% axes summing to rho(k) = C*exp(abs(log(EPS))/N(k)), where C is the 
% appropriate scaling for the interval [U.ends(k) U.ends(k+1)].
%
% If EPS is not supplied, then it is taken from chebfunpref('eps').
%   
% CHEBELLIPSEPLOT(U,EPS,K) plots the coefficients of the funs indexed 
% by the vector K. If U is a quasimatrix, only the first column / row
% is considered.
%
% CHEBELLIPSEPLOT(U,EPS,S) and CHEBPOLYPLOT(U,EPS,K,S) allow further plotting 
% options, such as linestyle, linecolor, etc. If K is a vector, then
% use CHEBPOLYPLOT(U,EPS,K,'.r'), etc to alter plot styles for all of the 
% funs given by K. 
%
% CHEBELLIPSEPLOT(U,...,'legends',0) will prevent the legends being
% displayed on the plot.
%
% H = CHEBELLIPSEPLOT(U) returns a handle H to the figure.
%
% Example
% u = chebfun({@sin @cos @tan @cot},[-2,-1,0,1,2]);
% chebellipseplot(u,sqrt(eps),'--');

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Default options
k = 0;                      % plot all funs by default
ee = chebfunpref('eps');    % Default EPS
numpts = 101;               % Numver of points in plots
legends = 1;                % Display legends?

% check inputs
if nargin > 1
    if isnumeric(varargin{1}), 
        if varargin{1} >= 1, 
            k = varargin{1};
        else
            ee = varargin{1};
            if numel(varargin) > 1 && isnumeric(varargin{2}), 
                k = varargin{2};
                varargin(2) = [];
            end
        end
        varargin(1) = [];
    end
    
    j = 1;
    while j < length(varargin)
        if strcmpi(varargin{j},'eps')
            ee = varargin{j+1}; 
            varargin(j:j+1) = [];
        elseif strcmpi(varargin{j},'numpts')
            numpts = varargin{j+1}; 
            varargin(j:j+1) = [];
        elseif strcmpi(varargin{j},'legends')
            legends = varargin{j+1}; 
            varargin(j:j+1) = [];
        else
            j = j+1;
        end
    end
end

if k == 0, k = 1:u.nfuns(1); end

if numel(u) > 1
    if u(1).trans, u = u(1,:);
    else           u = u(:,1);
    end
end
if any(k > u.nfuns)
    error('CHEBFUN:chebellipseplot:outofbounds', 'Input chebfun has only %d pieces', u.nfuns);
end

c = exp(2*pi*1i*linspace(0,1,numpts));

UK = {};
for j = k
    uk = u.funs(j);
    endsk = uk.map.par(1:2);
    rhok = exp(abs(log(ee))/uk.n);
    ek = .5*sum(endsk) + .25*diff(endsk)*(rhok*c+1./(rhok*c));
    UK = [UK, {real(ek), imag(ek)}, varargin]; % store
end

h = plot(UK{:});

if legends && j > 1
    legend(int2str(k.'))
end

% output handle
if nargout ~=0
    varargout = {h};
end

