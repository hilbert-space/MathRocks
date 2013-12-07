function [bol,wzero] = singlesigntest(F)
% Returns 1 if the chebfun2 evaluated on a Chebyshev tensor grid does not
% change sign. Used for check before applying abs, sqrt, log, etc. 
%
% wzero = 1 if a zero has been found. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.



bol = 0 ;   % assume false. 
wzero = 0;   % assume no zeros.

X = chebpolyval2(F);  % evaluate on a grid use FFTs. 

if ( all(all( X >=0 ))) 
    bol = 1; sgn = 1;  
elseif ( all(all( X <=0 )) )
    bol = 1; sgn = -1;  
end

if ( any ( any ( X == 0 ) ) ) 
    wzero = 1; 
end

end