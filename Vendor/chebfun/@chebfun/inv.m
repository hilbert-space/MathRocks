function g = inv(f,varargin)
% INV Invert a chebfun.
%
% G = INV(F) will attempt to invert the monotonic chebfun F.
% If F has zero derivatives at its endpoints, then it is advisable
% to turn Splitting ON.
%
% INV(F,'SPLITTING','ON') turns Splitting ON locally for the inv command.
%
% INV(F,'EPS',TOL) will construct with the relative tolerance set by TOL.
% If no tolerance is passed, TOL = chebfunpref('eps') is used.
%
% INV(F,'MONOCHECK','ON'/'OFF') turns the check for monotonicity ON or OFF
% respectively. It is OFF by default.
%
% G = INV(F,'RANGECHECK','ON'/'OFF') enforces that the range of G exactly
% matches the domain of F (by adding a linear function). RANGECHECK OFF is
% the default behaviour.
%
% Any of the preferences above can be used in tandem.
%
% Example: 
%   x = chebfun('x');
%   f = sign(x) + x;
%   g = inv(f,'splitting',true);
%
% Note, this function is experimental and slow! INV may be the better
% choice for piecewise functions, where as INV2 is good for smooth
% functions.
%
% See also chebfun/inv2

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% No quasimatrix support
if numel(f) > 1
    error('CHEBFUN:inv:noquasi','no support for quasimatrices');
end

% Default options
split_yn = chebfunpref('splitting');
tol = chebfunpref('eps');
monocheck = false;
rangecheck = false;

% Parse input
while numel(varargin) > 1
    if strcmpi(varargin{1},'splitting')
        split_yn = onoffcheck(varargin{2});
    elseif strcmpi(varargin{1},'eps')
        tol = varargin{2};
    elseif strcmpi(varargin{1},'monocheck')
        monocheck = onoffcheck(varargin{2});
    elseif strcmpi(varargin{1},'rangecheck')
        rangecheck = onoffcheck(varargin{2});
    else
        error('CHEBFUN:inv:inputs', ...
            [varargin{1}, 'is an unrecognised input to inv.']);
    end
    varargin(1:2) = [];
end

% turn splitting on if F is piecewise.
if length(f.ends) > 2 && ~(chebfunpref('splitting') || split_yn)
    split_yn = true;
end

% Monotonicity check
if monocheck
    tpoints = roots(fp);
    if ~isempty(tpoints)
        endtest = zeros(length(tpoints),1);
        for k = 1:length(tpoints)
            endtest(k) = min(abs(tpoints(k)-domainf.ends));
        end
        if any(endtest > 100*abs(feval(f,tpoints))*tol)
            error('CHEBFUN:inv:notmonotonic','chebfun F must be monotonic its domain.');
        elseif ~split_yn
            warning('CHEBFUN:inv:singularendpoints', ['F is monotonic, but ', ...
                'INV(F) has singular endpoints. Suggest you try ''splitting on''.']);
        end
    end
end

% compute the inverse
domaing = minandmax(f);
x = chebfun(@(x) x, domaing);
g = chebfun(@(x) op(f,x), domaing, 'resampling', 0,'splitting',split_yn,'eps',tol);

% Scale so that the range of g is the domain of f
if rangecheck
    [rangeg gx] = minandmax(g);
    g = g + (gx(2)-x)*(f.ends(1)-rangeg(1))/diff(gx) ...
        + (x-gx(1))*(f.ends(end)-rangeg(2))/diff(gx);
end
  
function r = op(f,x)
tol = chebfunpref('eps');
r = zeros(length(x),1);
% Vectorise
for j = 1:length(x)
    temp = roots(f-x(j));
    if length(temp) ~= 1
        fvals = feval(f,f.ends);
        err = abs(fvals-x(j));
        [temp k] = min(err);
        if err(k) > 100*tol*abs(fvals(k));
            error('CHEBFUN:inv:notmonotonic2','chebfun must be monotonic');
        end
    end
    r(j,1) = temp;
end


