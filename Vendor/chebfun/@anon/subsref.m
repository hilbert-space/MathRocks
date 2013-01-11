function varargout = subsref(an,index)
% SUBSREF for the anon class. At the moment, the only allowed subsref type
% is . and ().

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

idx = index(1).subs;
switch index(1).type
    case '.'
        switch(idx)
            case 'depth'
                varargout = {an.depth};
            case 'function'
                varargout = {an.func};
            case 'variablesName'
                varargout = {an.variablesName};
            case 'workspace'
                varargout = {an.workspace};
            case 'parent'
                varargout = {an.parent};
            otherwise
                error('ANON:get:propnam',[propName,' is not a varargoutid anon property.'])
        end
    case '()'
        anonType = an.type;
        if anonType == 1
            [varargout{1} varargout{2}] = feval(an,idx{1},anonType);
        else
            varargout{1} = feval(an,idx{1},anonType);
        end
    otherwise
        error('CHEBFUN:anon:subsref',['??? Unexpected index.type of ' index(1).type]);
    end
end