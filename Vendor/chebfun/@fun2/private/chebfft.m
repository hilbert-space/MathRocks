function Y = chebfft(X)
% Vectorised chebfun fft. Converts values to coefficients in vectorised
% way. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = size(X,1);
Y = [X(end:-1:1,:) ; X(2:end-1,:)]; % Laurent fold in columns.
if isreal(X)
    Y = fft(Y,[],1)/(2*n-2);
    Y = real(Y);
elseif isreal(1i*X)
    Y = fft(imag(Y),[],1)/(2*n-2);
    Y = 1i*real(Y);
else
    Y = fft(Y,[],1)/(2*n-2);
end
Y = Y(n:-1:1,:);
if (n > 2), Y(2:end-1,:) = 2*Y(2:end-1,:); end
end
