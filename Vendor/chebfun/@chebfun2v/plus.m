function f = plus( f , g ) 
% + PLUS of two chebfun2v objects. 
% 
% F + G if F and G are chebfun2v objects does componentwise addition. 
% 
% F + G if F is a double and G is a chebfun2v does componentwise addition. 
% 
% F + G if F is a chebfun2v and G is a double does componentwise addition. 
% 
% plus(F,G) is called for the syntax F + G. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( isa(f,'double') ) 
%% double + chebfun2v
    if (numel(f) == 1) 
        % Assume g + [f f].';
        const = f; f= g; 
        f.xcheb = plus(g.xcheb,const); 
        f.ycheb = plus(g.ycheb,const); 
        f.zcheb = plus(g.zcheb,const); 
    elseif ( ( numel(f) == 2 ) && isempty(g.zcheb) )
        const = f; f=g; 
        f.xcheb = plus(g.xcheb,const(1)); 
        f.ycheb = plus(g.ycheb,const(2)); 
    elseif ( numel(f) == 3 && ~isempty(g.zcheb) )
        const = f; f=g; 
        f.xcheb = plus(g.xcheb,const(1)); 
        f.ycheb = plus(g.ycheb,const(2)); 
        f.zcheb = plus(g.zcheb,const(3)); 
    else
        error('CHEBFUN2v:plus:double','Chebfun2v plus vector of length more than 2.');
    end
elseif ( isa(g,'double') ) 
%% chebfun2v + double 
    if (numel(g) == 1) 
        f = plus(g,f);
    elseif ( ( numel(g) == 2 ) && isempty(f.zcheb) )
        f = plus(g,f); 
    elseif ( ( numel(g) == 3 ) && ~isempty(f.zcheb) )
        f = plus(g,f); 
    else
        error('CHEBFUN2v:plus:double','Chebfun2v plus vector of length more than 2.');
    end
elseif (isa(f,'chebfun2v') && isa(g,'chebfun2v') )  
%% chebfun2v + chebfun2v
    if isempty(f.zcheb) && isempty(g.zcheb)
        temp = f;
        % plus componentwise.
        temp.xcheb = plus(f.xcheb,g.xcheb);
        temp.ycheb = plus(f.ycheb,g.ycheb);
        f=temp;
    elseif ~isempty(f.zcheb) && ~isempty(g.zcheb)
        temp = f;
        % plus componentwise.
        temp.xcheb = plus(f.xcheb,g.xcheb);
        temp.ycheb = plus(f.ycheb,g.ycheb);
        temp.zcheb = plus(f.zcheb,g.zcheb);
        f=temp;
    else
        error('CHEBFUN2V:PLUS','Chebfun2v size mismatch'); 
    end
else  % error
    error('CHEBFUN2v:plus:inputs','Chebfun2v can only plus to chebfun2v or double');
end
end