function varargout = subsref(f,index)
% SUBSREF   Chebfun subsref. 
% ( )
%   F(X) returns the values of the chebfun F evaluated on the array X. If F
%   is a column quasimatrix, then F(X,:) will evaluate each of the columns
%   at the points in the array X. F(X,I), where I is a vector of integers
%   in [0, numel(F)] returns the values of the columns indexed by I. F(:,I)
%   will extract the I chebfun columns indexed by I. For row quasimatrices
%   the order of the inputs is reversed.
% 
%   If X falls on a breakpoint of F, the corresponding value from F.IMPS is
%   returned. F(X,'left') or F(X,'right') will evaluate F to the left or
%   right of the breakpoint respectively.
%
%   F(G), where G is also a chebfun, computes the composition of F and G.
%
% .
%   F.PROP returns the property PROP of F as defined by GET(F,'PROP').
%
% {}
%   F{S} restricts F to the domain [S(1) S(end)] < [F.ENDS(1) F.ENDS(end)].
%
% See also CHEBFUN/FEVAL, CHEBFUN/GET, CHEBFUN/RESTRICT

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

idx = index(1).subs;
switch index(1).type
    case '.'
        varargout = get(f,idx);
        if ~iscell(varargout),
            varargout = {varargout};
        end
    case '()'
        % --- transpose row chebfuns/quasimatrices -------
        if get(f(1),'trans')   
            n = size(f,1);
            if length(idx) > 1,   s = idx{2}; % where to evaluate 
            else                  s = idx{1};            end
        else
            n = size(f,2);
            s = idx{1}; % where to evaluate
        end     
        % ---- read input arguments -----------------------------
        varin = {};
        if length(idx) == 1 
            % f(s), where s can be vector, domain, or ':'
            % syntax is not allowed when f is a quasimatrix
            if n ~= 1 && isnumeric(s)
               error('CHEBFUN:subsasgn:dimensions',...
                   'Index missing for quasi-matrix assignment.')
            end
            if strcmp(idx,':') 
                if n == 1 || get(f(1), 'trans')
                    varargout{1} = f;
                    return
                end
                % f(:) -> vertcat
                str = 'varargout{1} = vertcat(f(1)';
                for k = 2:numel(f)
                    str = [str ',f(' int2str(k) ')'];
                end
                str = [str ');'];
                eval(str);
                return
            end
        elseif length(idx) == 2
            % f(s,:), f(:,s), or, 
            if any(strcmpi(idx{2},{'left','right','-','+'}))
                varin = {idx(2)};
            elseif get(f(1),'trans')
                f = f(cat(2,idx{1}));
            else
                f = f(cat(2,idx{2}));
            end 
        elseif length(idx) == 3
            if any(strcmpi(idx{3},{'left','right'}))
                varin = {idx(3)};
            else
                error('CHEBFUN:subsref:dimensions',...
                'Index exceeds chebfun dimensions.')
            end
            if get(f(1),'trans')
                f = f(cat(2,idx{1}));
            else
                f = f(cat(2,idx{2}));
            end             
        else
            error('CHEBFUN:subsref:dimensions',...
                'Index exceeds chebfun dimensions.')
        end
        % ---- assign values/chebfuns at given points/domains ---        
        if isnumeric(s)
            varargout = { feval(f,s,varin{:}) };
        elseif isa(s,'domain')
            f = restrict(f,s);            
            varargout = { f };
        elseif isa(s,'chebfun') || isa(s,'function_handle')
            varargout = { compose(f,s) };
        % --------------------------------------------------------
        elseif isequal(s,':')
            varargout = { f }; 
        else
            error('CHEBFUN:subsref:nonnumeric',...
              'Cannot evaluate chebfun for non-numeric type.')
        end       
    case '{}'
        if numel(f) > 1,
            error('CHEBFUN:subsref:curly',...
              'Subsref does not support {} for quasimatrices. Use chebfun/restrict.');
        end
        if length(idx) == 1
            if isequal(idx{1},':')
%                 s = domain(f);
                varargout = {f};
                return
            else
                error('CHEBFUN:subsref:baddomain',...
                    'Invalid domain syntax.')
            end
        elseif length(idx) == 2
            s = cat(2,idx{:});
        else
            error('CHEBFUN:subsasgn:dimensions',...
                'Index exceeds chebfun dimensions.')
        end
        varargout = { restrict(f,s) };        
    otherwise
        error('CHEBFUN:UnexpectedType',...
            ['??? Unexpected index.type of ' index(1).type]);
end

if length(index) > 1
    varargout = {subsref([varargout{:}], index(2:end))};
end  
