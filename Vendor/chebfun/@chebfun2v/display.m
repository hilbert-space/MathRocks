function display(F)
% DISPLAY   Display a chebfun2v.
% 
% DISPLAY(F) outputs important information about the chebfun2v F to the
% command window, including its domain of definition, length (number of 
% pivots used to represent it), and a summary of its structure. 
%
% It is called automatically when the semicolon is not used at the
% end of a statement that results in a chebfun2v.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

loose = strcmp(get(0,'FormatSpacing'),'loose');
if loose
    fprintf('\n%s = \n\n',inputname(1))
else
    fprintf('%s = \n',inputname(1))
end

% compact version
if ( isempty(F) )
    fprintf('empty chebfun2v\n')
    return
elseif ( isempty(F.xcheb) && isempty(F.ycheb) )
    fprintf('empty chebfun2v\n')
    return
end

x_component = F.xcheb; 
y_component = F.ycheb; 
z_component = F.zcheb; 

if F.isTransposed
    tString = 'Row vector';
else
    tString = 'Column vector';
end

disp(['chebfun2v object ' '(' tString ')' ])

% Display its two chebfun2 halves.
display(x_component)
display(y_component)
if ( ~isempty(z_component) ) 
    display(z_component)
end

end