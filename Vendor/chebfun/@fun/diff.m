function g = diff(g,k)
% DIFF	Differentiation
% DIFF(G) is the derivative of the fun G.
%
% DIFF(G,K) is the K-th derivative of G.
%
% If the fun G of length n is represented as
%
%       SUM_{r=0}^{n-1} C_r T_r(x)
%
% its derivative is represented with a fun of length n-1 given by
%
%       SUM_{r=0}^{n-2} c_r T_r (x)
%
% where c_0 is determined by
%
%       c_0 = c_2/2 + C_1;
%
% and for r > 0,
%
%       c_r = c_{r+2} + 2*(r+1)*C_{r+1},
%
% with c_{n} = c_{n+1} = 0.
%
% See "Chebyshev Polynomials" by Mason and Handscomb, CRC 2002, pg 34.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(g), return, end
if nargin == 1, k = 1; end

if numel(g) > 1
    for j = 1:numel(g)
        g(j) = diff(g(j),k);
    end
    return
end

if nargin < 3
    c = chebpoly(g);  % obtain Cheb coeffs {C_r}
end
n = g.n;
ends = g.map.par(1:2);

% Separate in cases:

% 1 Linear map!
if strcmp(g.map.name,'linear')
    
    if ~any(g.exps) % simple case, no map or exponents
        for i = 1:k                             % loop for higher derivatives
            if n == 1,
                g = set(g,'vals',0); g.scl.v = 0; g.coeffs = 0;
                return
            end % derivative of constant is zero
            c = newcoeffs_der(c);
            n = n-1;
        end
        c = c/g.map.der(1).^k;
        g.vals = chebpolyval(c);
        g.coeffs = c;
        g.n = n;
%         g = fun(chebpolyval(c), g.map.par(1:2));
                
    else % function which blows up, need product rule
        
        for i = 1:k % loop for higher derivatives

            g = productrule(g);
            
        end
    end
    
% Unbounded map
elseif norm(g.map.par(1:2),inf) == inf
    nz = 2; % number of zeros needed to augment coefficients due chain rule
    infboth = false;
    if isinf(g.map.par(1)) && isinf(g.map.par(2))
        nz = 45;            % 1/derivative of this map requires length 45 to represent
        infboth = true;
    end
    
    if ~any(g.exps) % old case with no exponents
        for i = 1:k                             % loop for higher derivatives
            if n == 1,
                g = set(g,'vals',0); g.scl.v = 0; g.coeffs = 0;
                return
            end                                 % derivative of constant is zero
            % increase length because because degree increases with
            % derivatives (by 1);
            cout = newcoeffs_der([zeros(nz,1); c]);
            vals = chebpolyval(cout)./g.map.der(chebpts(n+nz-1));
            n = length(vals);
            g.n = n;
            g.vals = vals;
            c = chebpoly(g,2,'force');
            g.coeffs = c;
        end
        g.scl.v = max(g.scl.v,norm(vals,inf));
        if infboth
            g = simplify(g);
            if nargout > 1, c = chebpoly(g); end
        end
        
    else % apply product rule!

        for i = 1:k
            g = productruleinf(g);
        end

    end
        

% sing maps 
% A special case (as the map introduces exponents)    
elseif strcmp(g.map.name,'sing')
    
    for i = 1:k % loop for higher derivatives (note exps may be introduced by
                % differentiating here, so 'if' is inside 'for')
        if ~any(g.exps) % old case with no exponents
            
            if n == 1,
                g = fun(0,g.map.par(1:2));
                return
            end                                 % derivative of constant is zero
            
            % Compute derivative of g with respect to Cheby variable
            c = newcoeffs_der(c);
            vals = chebpolyval(c);
            
            map = g.map;
            par = g.map.par(3:4);
            newexps = par-1;

            if all(newexps)
                % Singmap at both ends (SLOW?)
                pref = chebfunpref;
                pref.extrapolate = true;
                pref.exps = newexps;
                if par(1) == .25
                    pref.n = length(vals)+23;
                    g = fun(@(x) bary(map.inv(x),vals)./map.der(map.inv(x)),map,pref);
                    g = simplify(g);
                else
                    pref.n = length(vals);
                    g = fun(@(x) bary(map.inv(x),vals)./map.der(map.inv(x)),map,pref);
                    
                    % this should also work, but one needs to find the constant
                    % ...
                    %             a = sum(par);
                    %             c = 4*a/diff(ends)^(a)/pi;
                    %             g = fun(vals*c, [-1 1]);
                    %             g.map = map;
                    %             g = setexps(g,newexps);
                end
            else
                % Voodoo ...
                par(par==1) = 0;
                a = sum(par);
                scl = 2*a/diff(ends)^(a);
                
                g = fun(vals*scl, [-1 1]);
                g.map = map;
                g = setexps(g,newexps);
            end
            
        else
            % This is the case of singmaps and exponents.
            % We use the product rule, and it turns out the tricky bit simplifys to
            % the case where there aren't exponents which is dealt with above.
            
            g = productrule(g);   
            
        end
        
    end
    
% General (MAP) case: (slow !!!)
else
    
    if ~any(g.exps) % old case with no exponents
        
        for i = 1:k                             % loop for higher derivatives
            if n == 1,
                g = set(g,'vals',0); g.scl.v = 0;
                return
            end                                 % derivative of constant is zero
            cout = newcoeffs_der(c);
            vals = chebpolyval(cout);
            g.vals = vals; g.scl.v = max(g.scl.v,norm(vals,inf));
            g.n = length(vals);
            map = g.map;
            g.map = linear([-1,1]);
            g = fun(@(x) feval(g,x)./map.der(x),[-1 1]); % construct fun from {c_r}
            g.map = map;
            if i ~= k || nargout > 1
                c = chebpoly(g);
                n = length(c);
            end
        end
        
    else % apply product rule!

        for i = 1:k
            g = productrule(g);
        end

    end

end


function cout = newcoeffs_der(c)
% C is the coefficients of a chebyshev polynomials (on [-1,1])
% COUT are the coefficiets of its derivative

n = length(c);
cout = zeros(n+1,1);                % initialize vector {c_r}
v = [0; 0; 2*(n-1:-1:1)'.*c(1:end-1)]; % temporal vector
cout(1:2:end) = cumsum(v(1:2:end)); % compute c_{n-2}, c_{n-4},...
cout(2:2:end) = cumsum(v(2:2:end)); % compute c_{n-3}, c_{n-5},...
cout(end) = .5*cout(end);           % rectify the value for c_0
cout = cout(3:end);

function g = productrule(g)
% Apply the product rule to differentiate functions with exponents
exps = g.exps;
g = setexps(g,[0 0]);
gp = diff(g);

if exps(1) && ~exps(2)                  % left exponent
    gp = setexps(gp, gp.exps+[1 0]);
    g = exps(1)*g+gp;
    g = setexps(g,g.exps+exps-[1 0]);
elseif ~exps(1) && exps(2)              % right exponent
    gp = setexps(gp, gp.exps+[0 1]);
    g = -exps(2)*g+gp;
    g = setexps(g,g.exps+exps-[0 1]);
else                                    % double exponent
    gp = setexps(gp, gp.exps+[1 1]);
    g = (exps(1)*setexps(g,[0 1])-exps(2)*setexps(g,[1 0]))+gp;
    g = setexps(g,g.exps+exps-[1 1]);
end


function g = productruleinf(g)
% Apply the product rule to differentiate functions with exponents on
% unbounded intervals

if ~strcmp(g.map.name,'unbounded')
    error('CHEBFUN:fun:diff','No support for nonstandard maps on infinite intervals')
end

g = replace_roots(g);
exps = g.exps;
if ~any(exps)
    g = diff(g);
    return
end
map = g.map;
s = map.par(3);
ends = map.par(1:2);
g.map = linear([-1 1]);
g = setexps(g,[0 0]); 

C = 1;
if all(isinf(ends)) 
    C = s*100./5; % I have absolutely no justification for this...
    % It may be that setexps isn't doing the right thing below.
    % but doing whatever it's doing, this works.
end
gp = diff(g);

if exps(1) && ~exps(2)                  % left exponent
    gp = setexps(gp,[1 0]);
    g = exps(1)*g+gp;
    g = setexps(g,exps+[1 0]);
elseif ~exps(1) && exps(2)              % right exponent
    gp = setexps(gp,[0 1]);
    g = -exps(2)*g+gp;
    g = setexps(g,exps+[0 1]);
else                                    % double exponent
    gp = setexps(gp, gp.exps+[1 1]);
    g = (exps(1)*setexps(g,[0 1])-exps(2)*setexps(g,[1 0]))+gp;
    g = C*setexps(g,exps+[1 1]).*fun(@(y) 1./(1+y.^2),[-1 1]);
end

g.map = map;




