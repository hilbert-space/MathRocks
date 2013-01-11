function varargout = pdeset(varargin)
%PDESET Set options for pde15s
% PDESET('NAME1',VALUE1,'NAME2',VALUE2,...) creates options for the
% Chebfun pde15s routine. It acts as a gateway to odeset for the usual
% ode options for use in advancing through time, in addition to some new
% options.
%
% OPTIONS = PDESET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
% structure OLDOPTS.
%
% PDESET PROPERTIES (In addition to ODESET properties)
%
% Eps - Tolerance to use in solving the PDE [ positive scalar {1e-6} ].
%
% N - Turn off spacial adaptivity. [{NaN} | positive integer  ]
%   Use a fixed spacial grid of size N. If N is NaN, then the automatic 
%   procedure is used.  
%
% Plot - Plot the solution at the end of every time chunk. [ {on} | off ]
%   Turning this off can improve speed considerably.
%
% HoldPlot - Hold the plots after each chunk. [ on | {off} ]
%
% YLim - Fix the limits of the Y axis if plotting. [ 2x1 vector | {NaN} ]
%   If Ylim is NaN then the imits are determined automatically.
%
% PlotStyle - Change the plotting options. [ string | ''-'' ].
%
% PDEflag - Specify which entries correspond to time derivatives. 
%   [  vector of logicals {true} ].
%
% Jacobian - set whether Chebfun should use AD functionality to determine 
%   the Jacobian function automatically, or allow ode15s to compute it
%   numerically with odenumjac. [{'auto'}, 'none']

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

names = ['Eps      ' 
         'N        '
         'Plot     '
         'HoldPlot '
         'YLim     '
         'PlotStyle'
         'PDEflag  ']; 
m = size(names,1);
shortnames = cell(m,1);
for k = 1:m
    shortnames{k} = strtrim(names(k,:));
end

% initialise
opts = {};
pdeopts = {};

if nargin == 0,
    if nargout == 0
        odeset;
        fprintf('             Eps: [ positive scalar {1e-6} ]\n')
        fprintf('               N: [ {NaN} | positive integer  ]\n')        
        fprintf('            Plot: [ {on} | off ]\n')
        fprintf('        HoldPlot: [ on | {off} ]\n')
        fprintf('            YLim: [ 2x1 vector | {NaN} ]\n')
        fprintf('       PlotStyle: [ string | ''-'']\n')
        fprintf('         PDEflag: [ vector of logicals {true} ]\n')
    else
        % Get the ode opts
        opts = odeset;
        % Add empty pde opts
        for j = 1:m
            opts.(shortnames{j}) = [];
        end
        varargout{1} = opts;
    end      

    return
end

% Is an odeset / pdeset structure being passed?
if isstruct(varargin{1})
    opts = varargin{1};
    varargin(1) = [];
end

% Remember the old pdeopt values
for k = 1:m
    namek = shortnames{k};
    if isfield(opts,namek)
        pdeopts = [ pdeopts {namek, opts.(namek)}];
    end
end

% Parse the remaining input and update pdeopts entries
k = 1;
while k < length(varargin)
    if ~any(strcmpi(fieldnames(odeset),varargin{k}))
        if strcmpi(varargin{k},'Plot') || strcmpi(varargin{k},'HoldPlot')
            varargin{k+1} = onoff(varargin{k+1});
        end
        pdeopts = [pdeopts varargin(k:k+1)];
        varargin(k:k+1) = [];
    else
        k = k+2;
    end
end

% Get the ode opts
opts = odeset(opts,varargin{:});

% Add empty pde opts
for j = 1:m
    opts.(shortnames{j}) = [];
end
% Attach the pde opts
for k = 1:2:length(pdeopts)
    for j = 1:m
        if strcmpi(pdeopts{k},shortnames{j})
            opts.(shortnames{j}) = pdeopts{k+1};
            break
        end
        if j == m 
            error('CHEBFUN:pdeset:UnknownOption',['Unrecognized property name ',pdeopts{k},'.'])
        end
    end
end

if isfield(opts,'Mass') && ~isempty(opts.Mass) && ~isa(opts.Mass,'chebop') 
    error('CHEBFUN:pdeset:Mass','Mass matrix must be a chebop.');
end

varargout{1} = opts;

function foo = onoff(foo)
% Convert logical values of 'on' or 'off'
if ~ischar(foo)
    if logical(foo)
        foo = 'on';
    else
        foo = 'off';
    end
end
        
    
    
