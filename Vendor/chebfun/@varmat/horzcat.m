function C = horzcat(varargin)
% HORZCAT  Horizontally concatenate varmats.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Take out empties.
empty = cellfun( @isempty, varargin );
varargin(empty) = [];

C = varmat( @hcat );

   function B = hcat(n)
     A = cellfun( @(A) feval(A,n), varargin, 'uniform',0);
     B = horzcat( A{:} );
     issp = cellfun( @issparse, A );
     if any(~issp), B = full(B); end
   end
 
 end