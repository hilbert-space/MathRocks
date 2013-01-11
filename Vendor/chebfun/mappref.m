function varargout = mappref(varargin)
% MAPPREF fun map preferences
%   MAPPREF by itself displays the current map preferences
%   MAPPREF(PREF), where PREF is 'NAME', 'ADAPT', 'PAR', 'ADAPTINF', and 
%   'PARINF' returns the corresponding preference value.
%   MAPPREF(PREF,VAL) assigns the value to the specified preference.
%
%   Example:
%       mappref('name', 'kt', 'adapt',false,'par', 0.9);
%       mapname = mappref('name')
%       mappref
%       mappref('adaptinf', true)

%   Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%   See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

persistent prefmap

% Default value
if isempty(prefmap)
    prefmap.name = 'linear';
    prefmap.adapt = false;
    prefmap.par = [];
    prefmap.adaptinf = false;
    prefmap.parinf = [1 0];
    mlock 
    % Use munlock (with filename) if you edit this file (or restart matlab).
end

% Display current preferences if no input is given
if nargin == 0
    varargout = {prefmap};
end

% Return current preference corresponding to input
if nargin == 1
    switch lower(varargin{1})
        case 'name'
            varargout = {prefmap.name};
        case 'adapt'
            varargout = {prefmap.adapt};
        case 'par'
            varargout = {prefmap.par};
        case 'adaptinf'
            varargout = {prefmap.adaptinf};
        case 'parinf'
            varargout = {prefmap.parinf};
        case 'factory'
            prefmap.name = 'linear';
            prefmap.adapt = false;
            prefmap.par = [];
            prefmap.adaptinf = false;
            prefmap.parinf = [1 0];
    end
end

% Assign preference 
if nargin > 1
    propertyArgIn = varargin;
    while length(propertyArgIn) >= 2
        prop = propertyArgIn{1};
        val = propertyArgIn{2};
        propertyArgIn = propertyArgIn(3:end);
        switch lower(prop)
            case 'name'
                if ~isa(val,'char')
                    error('CHEBFUN:mappref:input','Map name must be a string');
                end
                prefmap.name = val;
            case 'adapt'
                prefmap.adapt = val;
            case 'par'
                prefmap.par = val;
            case 'adaptinf'
                prefmap.adaptinf = val;
            case 'parinf'
                prefmap.parinf = val;
            otherwise
                error('CHEBFUN:mappref:input','Invalid option');
        end
    end
end
