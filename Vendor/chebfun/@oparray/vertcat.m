function A = vertcat(varargin)  
% VERTCAT   Vertically concatenate oparrays.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Take out empties.
empty = cellfun( @(A) isempty(A), varargin );
varargin(empty) = [];

op = {};
for k = 1:length(varargin)
  if isa(varargin{k},'function_handle')
      opk = varargin(k);
  else
      opk = varargin{k}.op;
  end
  op = vertcat(op,opk);
end

A = oparray(op);

end