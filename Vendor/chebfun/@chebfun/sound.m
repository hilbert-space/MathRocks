function sound(f,varargin)
%SOUND Play a chebfun as a sound.
% SOUND(F) overloads the MATLAB sound command for chebfuns
%
% See also sound, sing.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(f) > 1,
    error('CHEBFUN:sound:quasi','chebfun/sound is not defined for quasimatrices');
end

if isempty(f)
    f = chebfun(0);
end

[a b] = domain(f); 

n = 0;
for k = 1:f.nfuns
    n = n + f.funs(k).n;
end

Fs = 8192;
n = (b-a)*Fs;
x = linspace(a,b,n);
y = feval(f,x);

if numel(varargin) > 0
    sound(y,varargin{:});
else
    sound(y,Fs);
end

