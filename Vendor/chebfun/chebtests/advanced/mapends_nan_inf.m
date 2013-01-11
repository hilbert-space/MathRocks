function pass = mapends_nan_inf
% Tests for rounding errors on mapped endpoints and NaN and inf error 
% messages. Rodrigo Platte, July 2009

f = chebfun(@sin, [1e-200, 1-eps/2]);
pass(1) = f(1e-200) == sin(1e-200) &&  f(1-eps/2) == sin(1-eps/2);


return

% This call should return an error message - NOT ANYMORE!
%try
%    chebfun(@(x) sin(x)./x, [0, pi]);
%    pass(2) = false;
%catch
%    pass(2) = true;
%end

% % This call should return an error message
% try
%     chebfun(@(x) 1./x, [0, pi]);
%     pass(3) = false;
% catch
%     pass(3) = true;
% end
% 
% % This call should return an error message
% try
%     chebfun(@(x) sin(x)./(x-sqrt(2)), [0, pi],'splitting','on');
%     pass(4) = false;
% catch
%     pass(4) = true;
% end