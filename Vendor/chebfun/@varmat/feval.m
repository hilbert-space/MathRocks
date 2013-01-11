function C = feval(A,n)
% FEVAL  Realize a varmat matrix at given dimension.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

try
    C = A.defn(n);
catch ME
    if iscell(n) && all(cellfun(@isempty,n(2:3)))
        n = n{1};
        try
            C = A.defn(n);
        catch ME2
            rethrow(ME);
        end
    else
        rethrow(ME);
    end
end
        
if ~isempty(A.rowsel)
  C = C(A.rowsel(n),:);
elseif ~isempty(A.colsel)
  C = C(:,A.colsel(n));
end

end