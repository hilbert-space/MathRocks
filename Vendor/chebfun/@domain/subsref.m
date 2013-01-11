function t = subsref(d,s)
% SUBSREF Access data from a domain.
% Given domain D, D(1) and D(2) return the left and right endpoints of D.
% 
% D(:) or D.ends returns both endpoints as a vector.
%
% D.break returns the breakpoints (excluding endpoints). You can access a
% single breakpoint via D.break(I).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

valid = false;
switch(s(1).type)
  case '()'
    if isempty(d)
      error('DOMAIN:subsref:empty',...
        'Cannot reference an endpoint of an empty domain.')
    end
    k = s(1).subs{1};
    valid = true;
    if isequal(k,1)
      t = d.ends(1);
    elseif isequal(k,2)
      t = d.ends(end);
    elseif isequal(k,':')
      t = chebfun(@(x) x,d);
      %t = d.ends([1 end]);
    elseif isnumeric(k) && min(k)>0 && max(k)<=length(d.ends)
      t = domain(d.ends(k));
    else
      valid = false;
    end
  case '.'
    valid = true;
    switch(s(1).subs)
      case 'break'
        t = d.ends(2:end-1);
        if length(s)==2 && isequal(s(2).type,'()')
          if ~isequal(s(2).subs{1},':')
          t = t(s(2).subs{1});
          end
        end
      case 'ends'
        t = d.ends([1 end]);
      case 'endsandbreaks'
        t = d.ends;
      otherwise
        valid = false;
    end
end
        
if ~valid
  error('DOMAIN:subsref:invalid','Invalid reference.')
end
        
end