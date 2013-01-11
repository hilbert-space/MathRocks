function varargout = subsasgn(f,index,varargin)
%SUBSASGN   Modify a chebop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

idx = index(1).subs;
vin = varargin{:};
switch index(1).type
    case '.'
        varargout = {set(f,idx,vin)};
    otherwise
        error('CHEBOP:subsasgn:indexType',...
            ['Unexpected index.type of ' index(1).type]);
end