function fout = diag(L)
% DIAG The diagonal of linops
% F = DIAG(L) returns the chebfun that lies on the diagonal line of the
% linear operator L. Note that this is not well-defined if L is not a
% diagonal operator, and diag(L) issues a warning.
%
% If L is a 1xINF linop, then F = DIAG(L) returns a diagonal linop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(L), fout = chebfun; return, end

d = domain(L); d = d.endsandbreaks;
cheb1 = chebfun(1,d);
s = size(feval(L,3));

if s(1) > 1
    % Check whether L is truly a diagonal linop.
    if ~isdiag(L)
        warning('LINOP:diag',['Taking the diagonal of a nondiagonal ' ...
        'linop is not well defined.']);
    end
    fout = L*repmat(cheb1,1,L.blocksize(2));
else
    fout = linop( @(n) diag(feval(L,n{:})), L.oparray, L.domain, 0);
    fout.isdiag = 1;
end