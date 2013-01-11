function varargout = solve(guifile,handles)
% SOLVE Called when a user hits calls the solve method for a chebgui object
% outside the GUI (i.e. solve(cg))

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if strcmpi(guifile.type,'bvp')
    [varargout{1} varargout{2}] = solveguibvp(guifile);
elseif strcmpi(guifile.type,'pde')
    [varargout{1} varargout{2}] = solveguipde(guifile);
    if nargout < 2,
        varargout{1} = varargout{2};
    end
else
    [varargout{1} varargout{2}] = solveguieig(guifile);
    if nargout < 2,
        varargout{1} = diag(varargout{2});
    end
end