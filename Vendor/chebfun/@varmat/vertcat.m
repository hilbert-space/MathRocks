function C = vertcat(varargin)
% VERTCAT  Vertical concatenation of varmats.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Take out empties.
empty = cellfun( @isempty, varargin );
varargin(empty) = [];

C = varmat( @vcat );

   function B = vcat(n)
     A = cellfun( @(A) feval(A,n), varargin, 'uniform',0);
     B = vertcat( A{:} );
     issp = cellfun( @issparse, A );
     if any(~issp), B = full(B); end
   end
 
 end