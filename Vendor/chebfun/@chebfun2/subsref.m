function varargout = subsref(f,ref)
% SUBSREF Chebfun2 subsref
%
% ( )
%   F(X,Y) returns the values of the chebfun F evaluated on the array (X,Y).
%
%  .
%   F.PROP returns the property PROP of F as defined by GET(F,'PROP').
%
% { }
%    F{S} restricts F to the domain [S(1) S(2)] x [S(3) S(4)]

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

indx = ref(1).subs;

switch ref(1).type
    case '.'
        if ( numel(ref) == 1 )
            % This is a get call to get a property.
            varargout = { get(f,indx) };
            
        elseif ( strcmp(indx,'fun2') )
            % Trying to get a property from fun2 subclass. Allow this.
            fun = get(f,'fun2');
            subs = ref(2).subs;
            varargout = {get(fun,subs)};
            
        else
            t2 = indx(2).type;
            if ( strcmp(t2,'.') )
                out = get(f,indx,ref(2).subs{:});
            else
                out = get(f,indx);
                out = out(ref(2).subs{:});
            end
            
            if ( numel(ref) > 2 )
                varargout = {subsref(out,ref(3:end))};
            else
                varargout = {out};
            end
        end
    case '()'
        
        if ( length(indx) > 1 )
            x = indx{1}; y = indx{2}; % where to evaluate
        elseif ( any(isinf(size(indx{1}) )))
            if min(size(indx{1})) > 1
                error('CHEBFUN2:subsref','Cannot evaluate at a quasimatrix or chebfun2.')
            else
               % try and evaluate along chebfun. 
               varargout = {feval(f,real(indx{1}),imag(indx{1}))};
               return;
            end
        elseif ( size(indx{1},2) == 2 )
            % Matrix of evaluation points?
            pts = indx{1}; x = pts(:,1); y=pts(:,2);
            
        elseif ( size(indx{1},2) > 2 )
            % Matrix of evaluation points?
            error('CHEBFUN2:subsref','Cannot evaluate at an array of complex numbers.')
        else
            % Let's assume the input is complex and evaluate the function
            % on f(real(x),imag(x))
            x = real(indx{1}); y = imag(indx{1});
        end
        
        % ---- assign values/chebfuns at given points/domains ---
        if ( isnumeric(x) && isnumeric(y) )
            % check sizes 
            if all(size(x)==size(y))
                if min(size(x)>1)
                    if size(x,3)==1 && norm(diff(x,1,1))==0 && norm(diff(y,1,2))==0
                        % Evaluation is faster for data from meshgrid. 
                        varargout = { feval(f,x,y) };
                    else
                        % loop over to include evaluation at tensor. 
                        V = zeros(size(x));
                        for jj = 1:size(x,2)
                            for kk = 1:size(x,3)
                                V(:,jj,kk) = feval(f,x(:,jj,kk),y(:,jj,kk));
                            end
                        end
                        varargout = {V}; 
                    end
                else
                    varargout = { feval(f,x,y) };
                end
            else
                error('CHEBFUN:SUBSREF:SIZES','Sizes do not match.');
            end
        elseif ( isa(x,'chebfun') )
            varargout = { feval(f,x,y) };
        elseif ( isequal(x,':') )
            if ( isequal(y,':') )
                varargout = { f };
            elseif ( length(y) == 1 && isnumeric(y) )
                % It's a single chebfun2 so f(:,y) returns a chebfun.
                rect = f.corners;
                x = chebpts(length(f.fun2.R),rect(1:2));
                vals = feval(f,x,y);
                g = chebfun(vals,rect(1:2));
                varargout = {simplify(g)};
            end
        elseif ( isequal(y,':') && length(x) == 1 )
                rect = f.corners; y1 = rect(3); y2 = rect(4);
                g = chebfun(@(y) feval(f,x,y),[y1 y2],length(f.fun2.C));
                varargout = {simplify(g)};
        else
            error('CHEBFUN2:subsref:nonnumeric',...
                'nonnumeric value is not recognised.')
        end
    case '{}'
        if ( length(indx) == 1 )
            if isequal(indx{1},':')
                varargout = {f};
                return
            elseif ( isa(indx{1},'chebfun') )
                varargout = { restrict(f,indx{1}) };
                return
            else
                error('CHEBFUN2:subsref:baddomain',...
                    'Invalid domain syntax.')
            end
        elseif ( length(indx) == 4 )
            s = cat(2,indx{:});
        else
            error('CHEBFUN2:subsasgn:dimensions',...
                'Index exceeds chebfun2 dimensions.')
        end
        varargout = { restrict(f,s) };
    otherwise
        error('CHEBFUN2:UnexpectedType',['??? Unexpected index.type of ' index(1).type]);
end