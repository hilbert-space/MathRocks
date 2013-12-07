function display(F)
%DISPLAY   Display a chebfun2
% 
% DISPLAY(F) outputs important information about the chebfun2 F to the
% command window, including its domain of definition, length (number of 
% pivots used to represent it), and a summary of its structure. 
%
% It is called automatically when the semicolon is not used at the
% end of a statement that results in a chebfun2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%%
% Get display style and remove trivial empty chebfun2 case. 

loose = strcmp(get(0,'FormatSpacing'),'loose');
if ( loose )
    fprintf('\n%s = \n\n',inputname(1))
else
    fprintf('%s = \n',inputname(1))
end

% compact version
if ( isempty(F) )
    fprintf('      empty chebfun2\n\n')
    return
end

%%
% Get information that we want to display
rect = F.corners; 
len = length(F); 
xx = F.corners; [xx yy]=meshgrid(xx(1:2),xx(3:4));
vals = feval(F,xx,yy).'; vals = vals(:);   % values at the corners.

%% 
% Display information 

disp('chebfun2 object: (1 smooth surface)')
fprintf('       domain                 rank       corner values\n');

if(isreal(vals))
    fprintf('[%4.2g,%4.2g] x [%4.2g,%4.2g]   %6i     [%4.2g %4.2g %4.2g %4.2g]\n', rect(1), rect(2), rect(3) , rect(4) , len,vals);
else
    fprintf('[%4.2g,%4.2g] x [%4.2g,%4.2g]   %6i     [  complex values  ]\n', rect(1), rect(2), rect(3) , rect(4) , len);
end
fprintf('vertical scale = %3.2g \n', F.scl)

end