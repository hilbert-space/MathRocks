function I = integral(f,varargin)
%INTEGRAL Complete definite integral of chebfun2. 
%
% I = INTEGRAL(F), returns the definite integral of a chebfun2. Integrated
% over its domain of definition.
% 
% I = INTEGRAL(F,g), returns the integral of a chebfun2 along the curve
% defined by the complex-valued chebfun g. 
% 
% See also INTEGRAL2, SUM2, QUAD2D.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( nargin == 1 )
   I = integral2(f); 
else
    if ~isa(varargin{1},'chebfun')
        I = integral2(f,varargin{:});
    else
        x = varargin{1}; 
       % line integral along a complex valued chebfun. 
        if ( ~isreal(x) )
            % integral along the path of the complex-valued chebfun.
            I = sum(f.feval(x).*abs(diff(x)));
        else
            error('CHEBFUN2:integral:input','Integration path must be complex-valued');
        end
    end
end

end