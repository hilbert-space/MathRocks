function v = integral(F,c)
%INTEGRAL line integration of a chebfun2v
%
% INTEGRAL(F,C) computes the line integral of F along the curve C, that is
%
%                   
%                  /
% INTEGRAL(F,C) =  |  < F(r), dr > 
%                 /
%                 C 
%
% where the curve C is parameterised by the complex curve r(t).  

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ~isempty(F.zcheb)
    warning('CHEBFUN2V:INTEGRAL','Ignoring third component of chebfun2v.')
end


F1 = restrict(F.xcheb,c); F2=restrict(F.ycheb,c); 

dc = diff(c); 
v = sum(F1.*real(dc) + F2.*imag(dc)); 

end