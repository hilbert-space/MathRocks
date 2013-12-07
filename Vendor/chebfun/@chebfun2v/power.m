function f = power( f , g ) 
%.^ Componentwise power for chebfun2v.
%
% F.^G where F is a chebfun2v and G is a double returns the result from
% componentwise powers. 
%
% F.^G where F is a double and G is a chebfun2 returns from
% componentwise powers. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( isa(f,'double') ) 
%% double.^chebfun2v
    if ( numel(f) == 1 ) 
       const = f; f=g;
       f.xcheb = power(const,g.xcheb);
       f.ycheb = power(const,g.ycheb);
       f.zcheb = power(const,g.zcheb);
    elseif ( all(size(f) ==[2 1]) && isempty(g.zcheb) )
        const = f; f=g;
        f.xcheb = power(const(1),g.xcheb);
        f.ycheb = power(const(2),g.ycheb);
    elseif  ( all(size(f) ==[3 1]) && ~isempty(g.zcheb) )
        const = f; f=g;
        f.xcheb = power(const(1),g.xcheb);
        f.ycheb = power(const(2),g.ycheb); 
        f.zcheb = power(const(3),g.zcheb);
    else
        error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
    end
elseif (isa(g,'double') )   
%% chebfun2v.^double
    if ( numel(g) == 1 )
        const = g; temp=f;
        temp.xcheb = power(f.xcheb,const);
        temp.ycheb = power(f.ycheb,const);
        temp.zcheb = power(f.zcheb,const);
        f=temp; 
    elseif ( all(size(g) == [2 1] ) && isempty(g.zcheb) )
        const = g; temp=f;
        temp.xcheb = power(f.xcheb,const(1));
        temp.ycheb = power(f.ycheb,const(2));
        f=temp;
    elseif  ( all(size(f) ==[3 1]) && ~isempty(g.zcheb) )
        const = g; temp=f;
        temp.xcheb = power(f.xcheb,const(1));
        temp.ycheb = power(f.ycheb,const(2));
        temp.zcheb = power(f.zcheb,const(3));
        f=temp;
    else
        error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
    end
elseif (isa(f,'chebfun2v') && isa(g,'chebfun2v') )
%% chebfun2v.^chefun2v
    error('CHEBFUN2v:power:size','Chebfun2v dimension mismatch');
else  % error
    error('CHEBFUN2v:power:inputs','Cannot do this operation.');
end
end