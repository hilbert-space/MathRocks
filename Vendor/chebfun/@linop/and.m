function A = and(A,bc)
% &   Set boundary conditions for a linop.
% (A & BC) returns a linop the same as A but with boundary conditions
% defined by BC. Any previously defined boundary conditions for A 
% are discarded.
%
% There are multiple options for the BC part:
%
%   'dirichlet' or {'dirichlet',c} :  set value to zero or to c
%   'neumann' or {'neumann',c}     :  set derivative to zero or to c
%   B or {B,c}                     :  B is a linop defining the boundary operator          
%   'periodic'                     :  periodicity up to diff. order
%
% Alternatively, BC may be a struct with fields 'left', 'right', or 'bc'.
% To impose a single condition, each of these fields can take the form of
% any of the first three options above.
%
% If one wants to impose multiple conditions at one boundary, then the
% left/right/bc field of BC needs to be a struct array with fields 'op' and
% 'val'. For example:
%
%   lbc = struct( 'op', {'dirichlet','neumann'}, 'val', {1,0} );
%   bc = struct( 'left', lbc, 'right', struct([]) );
%   A = (A & bc);
%
% It may be more convenient in this context to use A.lbc and A.rbc 
% assignment syntax instead. See CHEBOP/SUBSASGN for more information.
%
% One use of & is to apply boundary conditions that were read off of
% another linop. For example, A = (A & B.bc)
%
% Note that A = (A & BC) is a synonym for A.bc = BC. However, the & syntax
% creates a new object that can be renamed or used inline as an argument to
% another function.
%
% See also linop/subsref, linop/subsasgn.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

A = setbc(A,bc);

end