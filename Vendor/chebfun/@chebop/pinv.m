function varargout = pinv(N,varargin)
%PINV  The pseudo-inverse of a finite-rank linear chebop.
%
% See also linop/svds.

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
        error('CHEBOP:norm',['Chebop appears to be nonlinear. Currently, norm only' ...
            '\nhas support for linear chebops.']);
    else
        rethrow(ME)
    end
end

[varargout{1:nargout}] = pinv(L,varargin{:});

end
