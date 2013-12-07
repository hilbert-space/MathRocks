function values = mysimplify(values,hscale,vscale,tol,force)
% This function removes leading Chebyshev coefficients that are below
% epsilon, relative to the verical scale stored in vscale. This function is
% a vectorised version on CHEBFUN/SIMPLIFY. In Version 5 when vector valued
% funCheb2 is available this script can be replaced. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 5, force = false; end

% Assume we're happy!
n = size(values,1); % assume we are given a column of values. 

% Deal with the trivial case (Can't be simpler than a constant!)
% if n < 2, coeffs = values; return, end  % this does not happen. 

% Get the defaults
% if nargin == 1
%     tol = chebfun2pref('eps');
% end
% if nargin < 3 || isempty(kind)
% %     kind = 2; % Second kind is default
% end
kind = 2; 
epstol = eps(1);

% Check the vertical scale
if vscale == 0,
    % Check for NaN's or Inf's
    if any(isnan(values))
        error('FUN2:simplify:naneval',...
            'Function returned NaN or Inf when evaluated.')
    end
    % g is the zero function
    values = 0;
    coeffs = 0;
    return
elseif any(isinf(vscale))
    % Inf located: try blowup?!
    return
end

% Get the coefficients
coeffs = chebfft(values);                    % Coeffs of Cheb expansion of g
ac = abs(coeffs)./vscale;                    % Abs value relative to scale of g

% NaNs are not allowed
if any(isnan(ac))
    error('FUN2:simplify:NaNEval', 'Function returned NaN when evaluated.')
end

% % Force simplification to a tolerance
% if nargin == 4 && force == 1
%     coeffs = coeffs(find(ac > tol,1):end);    % Chop the tail
%     v = fun.chebpolyval(coeffs,2);                % Values at 2nd kind points
%     if length(v) > 1 && kind == 2
%         % Force interpolation at endpoints
%         values = [values(1); v(2:end-1); values(end)];
%     else
%         values = v;
%     end
%     return
% end

Tlen = min(n,max(5,round((n-1)/8))); % Length of tail to test
% Which basically is the same as:
%  Tlen = n,             for n = 1:3
%  Tlen = 3,             for n = 4:25
%  Tlen = round((n-1)/8) for n > 25
x = chebpts(n,kind);
df = max(diff(x),eps*hscale);
mdiff =  (hscale/vscale)*max(abs(bsxfun(@rdivide,diff(values),df)));
% Choose maximum between prescribed tolerance and estimated rounding errors
Tmax = max(tol,epstol*min(1e12,max(mdiff,Tlen^(2/3)))); % Max size of tail
% ---------------------------------------------------

% Check for convergence and chop
if all(max(ac(1:Tlen,:)) < Tmax)        % We have converged; now chop tail
%     Tend = find(ac>=repmat(Tmax,size(ac,1),1),1,'first')-1; 
    Tend = find(max(ac,[],2)>=max(Tmax),1,'first')-1; % Pos of first entry above Tmax
    
    % Is g the zero function?
    if isempty(Tend)
        % g is the zero function
        values = 0;
        coeffs = 0;
        return
    end
     
    Tend = min(size(ac,1),Tend);    % hack to make things work on rare occasions. 
    ac = ac(1:Tend,:);                     % Restrict to coeffs of interest
    ac(1,:) = .225*tol;                    % <-- Why do we do this?
    for k = 2:Tend                       % Compute the cumulative max of
        ac(k,:) = max(ac(k,:),.225*tol);      %    the tail entries and .225*tol
    end
    Tbpb = log(1000*repmat(Tmax,size(ac,1),1)./ac)./ ...
        repmat(length(coeffs)-(1:Tend)',1,size(ac,2));       % Bang/buck of chopping at each pos
    [ignored,Tchop] = max(Tbpb(3:Tend,:)); % Tchop = pos at which to chop
    Tchop = min(Tchop); 
    
    % don't allow chopping so k < n 
    if (size(coeffs,1) - Tchop < size(coeffs,2)) 
        Tchop = 1; 
    end 
    
    coeffs = coeffs(Tchop+3:end,:);         % Chop the tail
    v = chebifft(coeffs);            % Values at 2nd kind points

    % Update values
    if length(v) > 1 && kind == 2
        % force interpolation at endpoints
        v(1,:) = values(1,:); v(end,:) = values(end,:); 
        values = v; 
%         values = [values(1); v(2:end-1); values(end)];
    else
        values = v;
    end
end