function varargout = subsasgn(f,index,varargin)
% SUBSASGN   Modify a chebfun.
%     F(I) = G assigns the chebfun G into the interval of the chebfun F specifed 
%     by the domain I. A(I,C) = F assigns the chebfun F to the column C of a 
%     quasi-matrix A.  A colon used as a subscript in the first argument, as in 
%     A(:,C) = F, indicates the entire chebfun column.
%  
%     F(PTS) = VALS assigns the values of vector VALS at locations
%     specified in vector PTS in the chebfun F. length(PTS) should be equal
%     to length(VALS). Subsasgn introduces new break-points in F at points
%     in PTS that were not before in F.ENDS. Similarly, A(PTS,C) = VALS
%     assigns values for specific points PTS of the column C of a
%     quasimatrix A.
%  
%     F{A,B} = G is a wrapper for the command DEFINE(F,[A,B],CHEBFUN(G,[A,B])).
%  
%     F.FIELD = B is a wrapper for the command SET(F,FIELD,B), where FIELD
%     is any of the chebfun fields.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

idx = index(1).subs;
vin = varargin{:};
switch index(1).type
    case '.'
        if length(index) > 2
            tmp = subsref(f,index(1:2));
            vin = subsasgn(tmp,index(3),vin);
            if strcmp(index(3).subs,'vals')
                vin = subsasgn(vin,struct('type','.','subs','n'),numel(vin));
            end
        end
        varargout = {set(f,idx,vin)};
    case '()'
        % --- transpose row chebfuns/quasimatrices -------
        trans = 0;
        if ~isempty(f) && get(f(1),'trans')
            trans = 1;
            f = f.';
            idx = fliplr(idx);
        end
        n = size(f,2);  
        s = idx{1};
        % ---- read input arguments -----------------------------
        if length(idx) == 1  
            % f(s), where s can be vector, domain or ':'
            % syntax is not allowed when f is a quasimatrix
            if n ~= 1
                error('CHEBFUN:subsasgn:dimensions',...
                    'Index missing for quasi-matrix assignment.')
            end
            col = 1;          
        elseif length(idx) == 2
            % f(s,col), where s can be domain, ':' or a vector
            % specifying the assigned columns.
            col = idx{2};
            if strcmp(col,':')
                col = 1:n;
            elseif max(col) > n
                % Create an empty chebfun if we're assigning to empty
                if isempty(f), f = chebfun; end
                % Convert doubles to constant chebfuns
                if isnumeric(vin)
                    if numel(col) ~= numel(vin)
                        error('CHEBFUN:subsassgn:double',...
                            'Quasimatrix dimensions do not agree.');
                    end
                    v = chebfun(vin(1),f(1).ends([1,end]));
                    for k = 2:numel(vin);
                        v(k) = chebfun(vin(k),f(1).ends([1,end]));
                    end
                    vin = v;
                end
                % Domain check to make sure chebfuns have same domain
                vdom = vin(1).ends([1,end]);
                if isempty(f(1)) || all(f(1).ends([1,end]) == vdom)
                    f(n+1:max(col)) = repmat(chebfun(0,vdom),1,max(col)-n);     
                else
                    error('CHEBFUN:subsasgn:domain','Inconsistent domains.')
                end
                
            end
        else
            error('CHEBFUN:subsasgn:dimensions',...
                'Index exceeds chebfun dimensions.')
        end

        if ~any(col)
            if islogical(col)
                varargout = {f};
                return
            else
                error('CHEBFUN:subsasgn:notlogical',...
                    'Subscript indices must either be real positive integers or logicals.');
            end
        end
        fcol = f(col);        
        
        % ---- assign values/chebfuns at given points/domains --- 
        if isa(s,'domain')
            fcol = define(fcol,s,vin);
        elseif isnumeric(s)
            if numel(s) == 1 && isa(vin,'chebfun')
                error('CHEBFUN:subsassgn:index','Invalid subscript assignment.');
            end
            fcol = define(fcol,s,vin);
        elseif strcmp(s,':')
            if isempty(fcol)
                fcol = define(fcol,domain(vin),vin);
            elseif isempty(vin)               
                indx = 1:numel(f); indx(col) = [];
                if ~isempty(indx)
                    f = f(indx);
                    if trans, f = f.'; end
                else
                    f(1) = chebfun;
                end
                varargout = { f }; 
                return
            else
                %fcol = define(fcol,domain(fcol),vin);
                fcol = restrict(vin,fcol.ends([1 end]));
            end
        else
            error('CHEBFUN:subsasgn:nonnumeric',...
              'Cannot evaluate chebfun for non-numeric type.')
        end
        % --- assign modified column to original chebfun/quasimatrix --
        % Check orientation - MATLAB supports this, so should we. NH Oct '11
%         if fcol(1).trans ~= trans
%             error('CHEBFUN:subsasgn:trans','Inconsistent chebfun transpose fields.')
%         else
        if fcol(1).trans
            fcol = fcol.';
        end
        f(col) = fcol;
        if trans, f = f.'; end
        varargout = { f };          
    case '{}'
        if numel(f) > 1,
            error('CHEBFUN:subsasgn:curly',...
              'Subsasgn does not support {} for quasimatrices. Use chebfun/define.');
        end
        if length(idx) == 1
            if isequal(idx{1},':')
                s = domain(f); 
%                 varargout = {f};
%                 return
            elseif isa(idx{1},'domain')
                s = idx{1};                 
            else
                error('CHEBFUN:subsasgn:baddomain',...
                    'Invalid domain syntax.')
            end
        elseif length(idx) == 2
            s = domain(cat(2,idx{:}));
        else
            error('CHEBFUN:subsasgn:dimensions',...
                'Index exceeds chebfun dimensions.')
        end
        % s should be a domain here
        varargout = { define(f,s,vin) };
    otherwise
        error('CHEBFUN:subsasgn:indextype',['??? Unexpected index.type of ' index(1).type]);
end