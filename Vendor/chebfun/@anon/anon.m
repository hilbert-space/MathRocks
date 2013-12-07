classdef anon < handle
% ANON constructor for the anon class, which is used to work with AD
% information (and oparrays) in Chebfun. Anons function in a similar way
% to anonymous functions in Matlab, but avoids memory overheads and
% inefficienies associated with anonymous functions.
%
% A = ANON(FUNC,VARIABLESNAME,WORKSPACE,TYPE,DEPTH, PARENT) returns an
% object of the class anon, where
%
%   FUNC is a string describing the commands which should be executed.
%   VARIABLESNAME is a cell-string, containing the names of the variables
%       involved.
%   WORKSPACE is a cell of variables (doubles or chebfuns), which contains
%       the values of the variables described in VARIABLESNAME.
%   TYPE is 1 if the anon is used for AD, 2 if it's used for oparrays.
%   DEPTH Describes how for away in the computational tree from the basis
%       variable (x) the anon is, and is used for memory control.
%   PARENT is a string which list in what chebfun method the anon was
%   created (used for plotting of anons).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    properties
        func = []
        variablesName = [];
        workspace = [];
        type  = 1;  % Type of anon. 1 for AD, 2 for regular @(u) anons.
        depth = [];
        parent = [];
    end
    
    methods
        function a = anon(varargin)
            maxdepth = chebfunpref('ADdepth');
            
            % Begin by checking whether we will be exceeding the maxdepth
            if nargin == 0 || ~maxdepth
                return
            elseif nargin > 4 && isnumeric(varargin{5})
                newdepth = varargin{5};
            else
                % Find information about the depths of the variables passed
                % in the workspace cell-array, storing the maximum depth.
                currdepth = 0;
                for vararginCounter = 1:length(varargin{3})
                    currVar = varargin{3}{vararginCounter};
                    if isa(currVar,'chebfun')
                        varDepth = getdepth(currVar);
                        if varDepth > currdepth
                            currdepth = varDepth;
                        end
                    end
                end
                newdepth = currdepth+1;
            end
            
            % If maxdepth is exceeded, return an empty anon
            if newdepth > maxdepth
                a.depth = maxdepth;
                return
            end
            
            % If not, continue and create the anon properly
            a.func = varargin{1};
            a.variablesName = varargin{2};
            a.workspace = varargin{3};
            a.type  = varargin{4};
            a.depth = newdepth;
            
            if nargin > 4 && ischar(varargin{5})
                a.parent = varargin{5};
            end

        end

%         function d = getdepth(an)
%         % GETDEPTH Obtain the AD depth of an anon
%         % D = GETDEPTH(AN) returns the depth of the anon AN.
% 
%         % Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%         % See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
% 
%         d = an.depth;
%         end

    end
    
end
