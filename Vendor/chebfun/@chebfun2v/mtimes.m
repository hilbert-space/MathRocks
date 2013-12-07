function f = mtimes( f , g ) 
%*  mtimes for chebfun2v. 
%
%  c*F or F*c multiplies each component of a chebfun2v by a scalar. 
% 
%  A*F multiplies the vector of functions F by the matrix A assuming that 
%  size(A,2) == size(F,1).
%
%  F*G calculates the inner product between F and G if size(F,3) ==
%  size(G,1). If the sizes are appropriate then F*G = dot(F.',G).
%
% See also TIMES.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 


% check for empty chebfun2v object. 
if isempty(f) || isempty(g)
   f = chebfun2v; % return empty object.  
   return; 
end

% If the chebfun2v object is transposed, then compute (g.'*f.').'
if ( isa(f,'chebfun2v') && ~isa(g,'chebfun2v'))
    if f.isTransposed
        f = mtimes(g.',f.');
        return;
    end
end
if (isa(g,'chebfun2v')&& ~isa(f,'chebfun2v') )
    if g.isTransposed
        f = mtimes(g.',f.').';
        return;
    end
end

if ( isa(f,'double') ) % double*chebfun2v
    if(numel(f) == 1)  % scalar*chebfun2v
        const = f; f = g; 
        f.xcheb = mtimes(g.xcheb,const);
        f.ycheb = mtimes(g.ycheb,const);
        f.zcheb = mtimes(g.zcheb,const);
    elseif numel(f) <= 9 
        if(size(f,1) == 1)
            % this is then the inner product so give back a chebfun2.
            const = f;
            if numel(f) == 2 && isempty(g.zcheb)
                f = mtimes(g.xcheb,const(1)) +...
                    mtimes(g.ycheb,const(2));  % return a chebfun2.
            elseif numel(f) == 3 && ~isempty(g.zcheb)
                const = f; 
                f = mtimes(g.xcheb,const(1)) +...
                    mtimes(g.ycheb,const(2)) +... 
                    mtimes(g.zcheb,const(3));  % return a chebfun2.
            else
               error('CHEBFUN2V:MTIMES:VECTORS','Size of vectors mismatch.') 
            end
        elseif(size(f,2) == 1)
            % componentwise multiplication by a vector.
            const = f; f=g;
            f.xcheb = mtimes(g.xcheb,const(1));
            f.ycheb = mtimes(g.ycheb,const(2));
            if numel(f) == 3 
               f.zcheb = mtimes(g.zcheb,const(3));  
            end
        elseif (size(f,2) == 2)
            % scalar matrix times chebfun2v so return a chebfun2v.
            const = f;   % size(const) = [2 2]
            temp = g; 
            temp.xcheb = mtimes(g.xcheb,const(1,1)) + mtimes(g.ycheb,const(1,2));
            temp.ycheb = mtimes(g.xcheb,const(2,1)) + mtimes(g.ycheb,const(2,2));
            if ~isempty(g.zcheb)
               error('CHEBFUN2V:MTIMES:SIZES','Mismatch of matrix and vector sizes.') 
            end
            f = temp; 
        elseif (size(f,2) == 3) 
            if isempty(g.zcheb)
               error('CHEBFUN2V:MTIMES:SIZES','Mismatch of matrix and vector sizes.') 
            end
            % scalar matrix times chebfun2v so return a chebfun2v.
            const = f;   % size(const) = [2 2]
            temp = g; 
            temp.xcheb = mtimes(g.xcheb,const(1,1)) + mtimes(g.ycheb,const(1,2)) + mtimes(g.zcheb,const(1,3));
            temp.ycheb = mtimes(g.xcheb,const(2,1)) + mtimes(g.ycheb,const(2,2)) + mtimes(g.zcheb,const(2,3));
            if size(const,1) > 2
                temp.zcheb = mtimes(g.xcheb,const(3,1)) + mtimes(g.ycheb,const(3,2)) + mtimes(g.zcheb,const(3,3));
            else 
                temp.zcheb = chebfun2;  % empty chebfun2. 
            end
            f = temp; 
        else
            error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
        end
    else
        error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
    end
elseif( isa(g,'double') ) % chebfun2v*double
    if(numel(g) == 1)  % chebfun2v*scalar
        f = mtimes(g,f);
    elseif( numel(g) == 2)
        if(size(g,2) == 1)
            % componentwise multiplication by a vector.
            const = g; temp=f;
            temp.xcheb = mtimes(g.xcheb,const(1));
            temp.ycheb = mtimes(g.ycheb,const(2));
            f=temp; 
        else
            error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
        end
    else
        error('CHEBFUN2v:mtimes:double','Chebfun2v and double size mismatch.');
    end
elseif (isa(f,'chebfun2v') && isa(g,'chebfun2v') ) % dot product if dimensions are right.
     if f.isTransposed && ~g.isTransposed
         f = dot(f,g);
     else
        error('CHEBFUN2v:mtimes:sizes','Inner dimensions must agree');
     end
elseif isa(f,'chebfun2v') && isa(g,'chebfun2')
    f = mtimes(g,f); 
else  % error
    error('CHEBFUN2v:mtimes:inputs','Chebfun2v can only mtimes to chebfun2v or double');
end
end