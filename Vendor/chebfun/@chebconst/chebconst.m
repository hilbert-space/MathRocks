classdef chebconst < chebfun
    properties
    end
    
    methods 
        function obj = chebconst(varargin)
            obj = obj@chebfun(varargin{:});
        end
        
        function [L nonConst] = diff(varargin)
            if nargin > 1 && isa(varargin{2},'chebfun')
                [L nonConst] = diff@chebfun(varargin{:});
%                 if ~isfinite(length(L)) % L is inf x inf
%                     L = full(diag(feval(L,1)));
%                 end
                if isa(varargin{1},'chebconst') && isa(varargin{2},'chebconst')
                    L = full(L(1));
                end
            else
                f = varargin{1}; 
                N = 1; dim = 1;
                if nargin > 1 && ~isempty(varargin{2}), N = varargin{2}; end
                if nargin > 2 && dim == varargin{2}; end
                if numel(f) == 1, L = chebconst(0,domain(f)); return, end
                L = f;
                for j = 1:N 
                   for k = 1:numel(L)-j
                       L(k) = L(k+1)-L(k);
                   end
                end
                L = L(1:numel(L)-j);
            end          
 
        end
        
        function g = double(f)
            n = numel(f);
            g = zeros(1,n);
            for k = 1:n
                v = get(f(k),'vals');
                g(k) = v(1);
            end
            if f(1).trans, g = transpose(g); end
        end
        
        function L = diag(f,d)
            if nargin == 1, d = domain(f); end
            if numel(f) > 1,
                error('CHEBFUN:chebconst:diag:quasi',...
                    'Quasimatrix input not allowed.');
            end
            if isempty(f),
                error('CHEBFUN:chebconst:diag:empty',...
                    'Enpty chebfun input not allowed.');
            end
            v = get(f(1),'vals'); const = v(1);
%             L = v(1)*eye(d);
            L = linop(@(n) const, @(u) times(const,u), d);
        end
        
        function g = sum(f)
            if isempty(f), g = []; return, end
            g = 0*f(1);
            for k = 1:numel(f)
                g = plus(g,f(:,k));
            end
            g.trans = f(1).trans;
        end
        
        function g = mean(f)
            if isempty(f), g = []; return, end
            g = sum(f)./numel(f);
        end
        
        function h = plus(f,g)
            if isa(f,'chebconst') && isa(g,'chebconst')
                df = domain(f); dg = domain(g);
                dom = [min(df(1),dg(1)), max(df(end),dg(end))];
                f = newdomain(f,dom); g = newdomain(g,dom);
            end
            h = plus@chebfun(f,g);
        end
        
        function h = minus(f,g)
            if isa(f,'chebconst') && isa(g,'chebconst')
                df = domain(f); dg = domain(g);
                dom = [min(df(1),dg(1)), max(df(end),dg(end))];
                f = newdomain(f,dom); g = newdomain(g,dom);
            end
            h = minus@chebfun(f,g);
        end
        
        function h = mtimes(f,g)
            if isempty(f), h = f; return, elseif isempty(g), h = g; return, end
            if isnumeric(f) || isnumeric(g), h = mtimes@chebfun(f,g); return, end
            [mf nf] = size(f); [mg ng] = size(g);
%             if ~isfinite(mf) || ~isfinite(ng)
%                 error('CHEBFUN:chebconst:mtimes:outerp',...
%                     'Outer products not yet implemented for chebconsts.');
%             end
            if (mf == 1 || ng == 1) && (get(f,'funreturn') || get(g,'funreturn'))
                h = chebconst;
                for j = 1:numel(f)
                    for k = 1:numel(g)
                        h(j,k) = times(f(j),g(k));
                    end
                end
            else
%                 if isa(f,'chebconst'), f = double(f); end
%                 if isa(g,'chebconst'), g = double(g); end
%                 h = mtimes(f,g);
                h = times(f,g);
            end
        end
        
        function g = mpower(f,a)
            if isnumeric(a)
                g = power(f,a);
            else
                error('CHEBFUN:chebconst:mpower:undef',...
                    'Undefined function ''mpower'' for input arguments of type ''chebfun''.');
            end
        end
                
        
        function g = feval(f,varargin)
            g = zeros(1,numel(f));
            if ~isempty(f) && get(f(1),'trans'), g = g.'; end
            for k = 1:numel(f)
                vals = get(f(k),'vals');
                g(k) = vals(1);
            end
        end
    end
end

    