function d = det(N,varargin)
%DET   Determinant of a linear chebop
% Compute the determinant of a linear operator. This is a well-defined
% notion for trace-class perturbations of the identity operator. Most
% notably, for perturbations that are Fredholm integral operators, this
% gives the famous Fredholm determinant.
%
% Example: 
%   F = chebop(@(x,u) u + fred(@(x,y) sin(x-y),u));
%   d = det(F);
%   disp([d ; (cos(4)+15)/8]);
%
% See also linop/det.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Linearize and check whether the chebop is linear
try
    L = linop(N);
    if ~isempty(varargin) && isa(varargin{1},'chebop')
        varargin{1} = linop(varargin{1});
    end
catch ME
    if strcmp(ME.identifier,'CHEBOP:linop:nonlinear')
        error('CHEBOP:eigs',['Chebop appears to be nonlinear. Currently, det only' ...
            '\nhas support for linear chebops.']);
    else
        rethrow(ME)
    end
end

d = det(L,varargin{:});

end
