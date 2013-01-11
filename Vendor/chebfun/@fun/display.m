function display(g)
% DISPLAY	Display fun
% DISPLAY(G) is called when the semicolon is not used at the end of a statement.
% DISPLAY(G) shows the type of fun and the function values at the
% Chebyshev points.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isequal(get(0,'FormatSpacing'),'compact')
    if numel(g) == 1
      if (isempty(g))
        disp([inputname(1) ' = empty fun'])
      else
        disp([inputname(1) ' = column fun'])
        disp([g.vals])
      end      
    else
        disp([inputname(1) ' = vector of funs'])
        for k = 1:numel(g)
            disp(['length of fun' num2str(k) ': ' num2str(length(g(k)))]);
        end
    end 
else
    if numel(g) == 1        
        if (isempty(g))
            disp(' ')
            disp([inputname(1) ' = empty fun'])
            disp(' ')
        else
          disp(' ')
          disp([inputname(1) ' = column fun']);
          disp(' ')
          disp([g.vals])
          disp(' ')
        end
    else
        disp(' ')
        disp([inputname(1) ' = vector of funs'])
        disp(' ')
        for k = 1:numel(g)
            disp(['length of fun ' num2str(k) ': ' num2str(length(g(k)))]);
        end
        disp(' ')
    end     
end