function g = ctor(g,op,ends,varargin)
% CTOR  fun constructor
% See also FUN

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


    nin = nargin - 1;

    if nin == 0, return; end                 % Return empty fun
    if nin == 1
        if isa(op,'fun'), g = op; return, end   % Returns the same fun
        error('FUN:fun:ends','Either endpoints or a map must be provided.')
    end

    % Default preferences
    pref = chebfunpref;
    pref.n = 0;                                 % Adaptive case by default
    if nin > 2
        if isa(varargin{1},'struct')
            % Preferences passed
            pref = varargin{1};
            if ~isfield(varargin{1},'n')
                pref.n = 0;                     % Adaptive case
            end
        else
            % Preferences not passed, just n
            pref.n = varargin{1};               % Non-adaptive case
        end
    end
    % Switch NaNs (for adaptive case) to zeros.
    if isnan(pref.n), pref.n = 0; end

    %% Deal with endpoints and maps
    if ~isnumeric(ends)
        % A map may optionally be passed in the second arg.
        g.map = ends;
%         ends = ends.for([-1,1]);
        ends = ends.par(1:2);
    elseif any(isinf(ends))
        % The default unbounded map.
        g.map = unbounded(ends);
    else
        g.map = linear(ends);
        %     The default map (taken from mappref)
        %     mpref = mappref;
        %     g.map = maps(fun,{mpref.name,mpref.par},ends);
    end

    %% Set horizantal scale if not provided
    if nin < 4 || isempty(varargin{2})
        hs = norm(ends,inf);
        if hs == inf,  hs = 2;  end
        g.scl = struct('h',hs,'v',0);
    else
        g.scl = varargin{2};
    end

    %% Deal with input op type
    switch class(op)
        case 'fun'      % Returns the same fun
            g = op;
            if nin > 2
                warning('FUN:constructor:input',['Generating fun from fun on the first' ...
                    ' input argument. Other arguments are not used.'])
            end
            g.ish = true;
            return
        case 'double'   % Assigns value to the Chebyshev points

            if min(size(op)) > 1
                error('FUN:constructor:double','Only vector inputs are allowed.')
            end
            if nin > 2 && pref.n
                warning('FUN:constructor:input',['Generating fun from double object on the first' ...
                    ' input argument. Other arguments are not used.'])
            end
            vals = op(:);
            g.n = length(op); g.vals = vals;
            if pref.chebkind == 1
                % Place values back in chebpoints of second kind.
                coeffs = chebpoly(g,1); 
                g.vals = chebpolyval(coeffs);
            else
                coeffs = chebpoly(g,2);   
            end
            % Assign data to the fun.
            g.coeffs = coeffs; g.scl.v = max(g.scl.v, norm(op,inf));
            if isfield(pref,'exps') && ~any(isnan(pref.exps)) && ~any(isinf(pref.exps)),
                g.exps = pref.exps;
            else
                g.exps = [0 0];
            end
            g.ish = true;
            return
        case 'char'
            % Convert string input to anonymous function.
            op = str2op(op);
    end
    
    %% Deal with empty intervals
    if ends(1) == ends(end)
        g = ctor(g,op(ends(1)),ends,varargin{:});
        return
    end

    %% Deal with unbounded functions on infinite intervals
    infends = isinf(ends);
    if any(infends)
        % Remember the op, and define a new one including the unbounded map.
        oldop = op;         op = @(x) op(g.map.for(x));
        if ~isfield(pref,'exps'),
            % If there aren't any exps, then assign some.
            if pref.blowup > 0, pref.exps = [NaN NaN];
            else                pref.exps = [0 0]; end
        else
            % Exponents on unbounded intervals are negated (from the user's perspective).
            if infends(1),  pref.exps(1) = -pref.exps(1); end
            if infends(2),  pref.exps(2) = -pref.exps(2); end
        end
        % This is a dirty check for functions which appear to blowup at infinity.
        % We check for infinite values, NaN's for very large x, and functions
        % with a positive (negative) gradient very near plus (minus) infinity.
        if infends(1) && ~isnan(pref.exps(1)) && ~pref.exps(1) && pref.blowup >=0
            vends = op([-1 ; -1+2*eps ; -1+4*eps]);
            if isinf(vends(1)) || any(isnan(vends(2:3))) || real(-sign(vends(3))*diff(vends(2:3))) > 1e4*pref.eps;
                pref.blowup = blowup(NaN);
                pref.exps(1) = NaN;
            end
        end
        if infends(2) && ~isnan(pref.exps(2)) && ~pref.exps(2) && pref.blowup >=0
            vends = op([1-4*eps ; 1-2*eps ; 1]);
            if isinf(vends(3)) || any(isnan(vends(1:2))) || real(sign(vends(1))*diff(vends(1:2))) > 1e4*pref.eps;
                pref.blowup = blowup(NaN);
                pref.exps(2) = NaN;
            end
        end
    end
    if pref.blowup < 0, pref.blowup = 0; end

    %% Find exponents
    % If op has blow up, we represent it by
    %      op(x) ./ ( (x-ends(1))^exps(1) * (ends(2)-x)^exps(2) )
    if isfield(pref,'exps')
        exps = pref.exps;
        if ~pref.blowup, pref.blowup = blowup(NaN); end % Get the default 'on' option
        if all(isnan(pref.exps))                        % No exps given
            exps = findexps(op,ends,0,pref.blowup);
        elseif isnan(exps(2))                           % Left exp given
            exps(2) = findexps(op,ends,1,pref.blowup);
        elseif isnan(exps(1))                           % Right exp given
            exps(1) = findexps(op,ends,-1,pref.blowup);
        end
    elseif pref.blowup
        % Blowup flag present. Check for blowup.
        exps = findexps(op,ends,0,pref.blowup);
    else
        % Standard representation - No blowup.
        exps = [0 0];
    end
    g.exps = exps;                                      % Assign exponents to fun

    % Scaling for funs on bounded intervals with exponents.
    if any(exps) && ~any(infends)
        rescl = (2/diff(ends))^-sum(exps);
        op = @(x) rescl*op(x)./((x-ends(1)).^exps(1).*(ends(2)-x).^exps(2)); % New op
    end

    % Scaling for funs on unbounded domain (possibly with exponents.)
    if any(infends)
        s = g.map.par(3);
        if all(infends),           rescl = .5/(5*s);
        else                       rescl = .5./(15*s);    end
        rescl = rescl.^sum(-exps); op = oldop;
        if any(exps)
            op = @(x) rescl*op(x)./((g.map.inv(x)+1).^exps(1).*(1-g.map.inv(x)).^exps(2)); % New op
        end
    end
    
    %% Call constructor
    if pref.n
        % Non-adaptive case (exact number of points provided).
        x = chebpts(pref.n,pref.chebkind);
        xvals = g.map.for(x);
        vals = op(xvals);
        g.vals = vals;    g.n = pref.n;
        if g.n > 2 && (any(g.exps) || any(isnan(vals)) || any(isinf(g.map.par([1 2])))) || pref.extrapolate || pref.splitting
            % Extrapolate only in special cases
            g = extrapolate(g,pref,x);
        else
            g.scl.v = max(g.scl.v,norm(vals,inf));
        end
        if pref.chebkind == 1
            % Place values back in chebpoints of second kind
            c = chebpoly(g,1);
            g.vals = chebpolyval(c,2);
        else
            c = chebpoly(g);
        end
        g.coeffs = c;
        g.ish = true;
    else
        % Adaptive case
        % If map was provided in the chebfun call then overwrite previous assignment.
        if isfield(pref,'map')
            if iscell(pref.map)
                mapfun = str2func(pref.map{1});
                par = g.map.par(1:2);
                if length(pref.map) == 2
                    par = [par pref.map{2}(:).'];
                end
                g.map = mapfun(par);
            else
                g.map = pref.map;
            end
        end
        % Call growfun to adaptivly construct the fun.
        g = growfun(op,g,pref);
    end

end

function op = str2op(op)
% This is here as it's a clean function with no other variables hanging around in the scope.
    depvar = symvar(op);
    if numel(depvar) ~= 1,
        error('CHEBFUN:fun:depvars',...
            'Incorrect number of dependent variables in string input.');
    end
    op = eval(['@(' depvar{:} ')' op]);
end
