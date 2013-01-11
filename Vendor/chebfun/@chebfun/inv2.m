function g = inv2(f,varargin)
% INV2 Invert a chebfun.
%
% G = INV2(F) will attempt to invert the monotonic chebfun F.
% If F has zero derivatives at its endpoints, then it is advisable
% to turn Splitting ON.
%
% INV2(F,'SPLITTING','ON') turns Splitting ON locally for the inv command.
%
% INV2(F,'EPS',TOL) will construct with the relative tolerance set by TOL.
% If no tolerance is passed, TOL = 100*chebfunpref('eps') is used. EPS
% should be set to at least a factor of 100 larger than the accuracy of F.
%
% INV2(F,'MONOCHECK','ON'/'OFF') turns the check for monotonicity ON or OFF
% respectively. It is OFF by default.
%
% G = INV2(F,'RANGECHECK','ON'/'OFF') enforces that the range of G exactly
% matches the domain of F (by adding a linear function). RANGECHECK OFF is
% the default behaviour.
%
% Any of the preferences above can be used in tandem.
%
% Example:
%   f = chebfun(@(x) tanh(7*x)./tanh(7)+1, [-.5 .5]);
%   g = inv2(f,'splitting','off','rangecheck','off','monocheck','off');
%
% Note, this function is experimental and slow! INV may be the better
% choice for piecewise functions, where as INV2 is good for smooth
% functions.
%
%  See also chebfun/inv

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% No quasimatrix support
if numel(f) > 1
    error('CHEBFUN:inv:noquasi','no support for quasimatrices');
end

% Default options
split_yn = chebfunpref('splitting');
tol = 100*chebfunpref('eps');
monocheck = false;
rangecheck = false;

% Parse input
while numel(varargin) > 1
    if strcmpi(varargin{1},'splitting')
        split_yn = onoffcheck(varargin{2});
    elseif strcmpi(varargin{1},'eps')
        var2 = varargin{2};
        if var2 < tol
            warning('CHEBFUN:inv2:eps', ...
            'EPS must be at least 100*chebfunpref(''eps'')');
        else
            tol = var2;
        end
    elseif strcmpi(varargin{1},'monocheck')
        monocheck = onoffcheck(varargin{2});
    elseif strcmpi(varargin{1},'rangecheck')
        rangecheck = onoffcheck(varargin{2});
    else
        error('CHEBFUN:inv2:inputs', ...
            [varargin{1}, 'is an unrecognised input to inv2.']);
    end
    varargin(1:2) = [];
end

% Turn splitting on if F is piecewise.
if length(f.ends) > 2 && ~(chebfunpref('splitting') || split_yn)
    split_yn = true;
end

% Compute the derivative
fp = diff(f);

% Monotonicity check
if monocheck
    tpoints = roots(fp);
    if ~isempty(tpoints)
        endtest = zeros(length(tpoints),1);
        for k = 1:length(tpoints)
            endtest(k) = min(abs(tpoints(k)-domainf.ends));
        end
        if any(endtest > 100*abs(feval(f,tpoints))*tol)
            error('CHEBFUN:inv2:notmonotonic','chebfun F must be monotonic its domain.');
        elseif ~split_yn
            warning('CHEBFUN:inv2:singularendpoints', ['F is monotonic, but ', ...
                'INV2(F) has singular endpoints. Suggest you try ''splitting on''.']);
        end
    end
end

% Prolong fp to be the same length as f (to make evaluation faster in 'op' below).
if f.nfuns == 1 && ~any(f.funs(1).exps)
    fp.funs(1) = prolong(fp.funs(1),f.funs(1).n);
end

% Compute the inverse
domaing = minandmax(f).';
x = chebfun('x',domaing);
g = chebfun(@(x) op2(f,fp,x,tol), domaing,'resampling',0,'splitting',split_yn,'eps',tol,'minsamples',length(f));

% Scale so that the range of g is the domain of f
if rangecheck
    [rangeg gx] = minandmax(g);
    g = g + (gx(2)-x)*(f.ends(1)-rangeg(1))/diff(gx) ...
        + (x-gx(1))*(f.ends(end)-rangeg(2))/diff(gx);
end

function r = op2(f,fp,x,tol)
tol = tol/5;

N = length(x);
if N == 2, r = 0*x; return, end
r = zeros(N,1);

% First root
t = f.ends(1);

if f.nfuns == 1 && ~any(f.funs(1).exps)
    % If we're dealing with just a simple fun, we hardwire
    % the barycentric formula to reduce overheads.
    fvals = f.funs(1).vals;
    fpvals = fp.funs(1).vals;
    n = f.funs(1).n;
    xk = f.funs(1).map.for(chebpts(n));
    ek = [.5 ; ones(f.funs(1).n-1,1)];
    ek(2:2:end) = -1;
    ek(end) = .5*ek(end);
    
    cmax = 10;
    % Vectorise
    for j = 1:N
        counter = 0;
        xx = ek./(t-xk); sumxx = sum(xx);
        ft = (xx.'*fvals)/sumxx-x(j);
        if isnan(ft)
            ft = fvals(find(t==xk,1))-x(j);
        end
        
        % Newton Iteration
        while abs(ft) > tol 
            counter = counter + 1;
            % Evaluate fp
            fpt = (xx.'*fpvals)/sumxx;
            if isnan(fpt)
                fpt = fpvals(find(t==xk,1));
            end
            
            % The step
            t = t - ft./fpt;
            
            if isempty(t), t = NaN; break, end
            
            % Evaluate f
            xx = ek./(t-xk); 
            sumxx = sum(xx);
            ft = (xx.'*fvals)/sumxx-x(j);
            if isnan(ft)
                ft = fvals(find(t==xk,1))-x(j);
            end
            
            % Bail-out clause
            if counter > cmax, break, end
        end
        
        % The value of the inverse.
        if counter > cmax
            % Should we set this to NaN if we bail out of the Newton iteration?
            r(j) = NaN;
%             r(j) = t;
        else
            r(j) = t;
        end
    end
    
else
    % We don't do this trick (doing feval by hand) with general chebfuns, 
    % as it would get too messy.
    
    % Vectorise
    for j = 1:N
        ft = feval(f,t)-x(j);
        while abs(ft) > tol % Newton step
            fpt = feval(fp,t);
            t = t - ft./fpt;
            ft = feval(f,t)-x(j);
        end
        r(j,1) = t;
    end
    
end

function value = onoffcheck(value)
if ischar(value)
    % If ON or OFF used -> change to true or false
    if strcmpi(value,'on'),       value = true;
    elseif strcmpi(value,'off'),  value = false; end
else
    value = logical(value);
end