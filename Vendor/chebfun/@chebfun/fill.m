function varargout = fill(varargin)
% FILL Filled 2-D chebfun plots.
% 
% FILL(F,G,C) fills the 2-D region defined by chebfuns F and G
% with the color specified by C. If necessary, the region is closed by
% connecting the first and last point of the curve defined by F and G.
%
% If C is a single character string chosen from the list 'r','g','b',
% 'c','m','y','w','k', or an RGB row vector triple, [r g b], the
% polygon is filled with the constant specified color.
%
% If F and G are quasimatrices of the same size, one region per column
% is drawn.
%
% If either of F or G is a quasimatrix, and the other is a single
% chebfun, the single chebfun argument is replicated to produce a
% quasimatrix of the required size.
%
% FILL(F1,G1,C1,F2,G2,C2,...) is another way of specifying
% multiple filled areas.
%
% FILL sets the PATCH object FaceColor property to 'flat', 'interp',
% or a colorspec depending upon the value of the C matrix.
%
% H = FILL(...) returns a column vector of handles to PATCH objects,
% one handle per patch. The F,G,C triples can be followed by
% parameter/value pairs to specify additional properties of the patches.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

[a,b] = domain(varargin{1});

t = linspace(a,b,1000)';

for k = 1:nargin
    if isa(varargin{k},'chebfun')
        varargin{k} = feval(varargin{k},t);
    end
end

h = fill(varargin{:});

if nargout > 0
    varargout = {h};
end
    