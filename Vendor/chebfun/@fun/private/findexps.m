function exps = findexps(op,ends,leftrightflag,integerflag)
%FINDEXPS Find chebfun exponents
% EXPS = FINDEXPS(H,ENDS) returns a vector EXPS such that
% H(X).*(X-ENDS(1)).^EXPS(1).*(X+ENDS(2)).^EXPS(2) is a bounded function

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Rodrigo Platte & Nick Hale  2009

if nargin < 3, leftrightflag = 0; end
if nargin < 4, integerflag = 2; end

if integerflag == 0
    if leftrightflag, exps = 0;
    else exps = [0 0]; end
    return
end

dbz_state = warning('off','MATLAB:divideByZero');   % turn off warning because of removable sings

if any(isinf(ends)) % Unbounded domains are mapped to [-1 1];
    ends = [-1 1];
end

% % Quick check values near endpoints! Is this still needed?
% gends = op(ends);
% if ~any(isinf(gends))
%     xvals = [ -0.616227322745569
%         0.718984852785806];
%     gvals = op(ends(2)*(xvals+1)/2+ends(1)*(1-xvals)/2);
%     if norm(gends,inf) < 1e4*norm(gvals,inf),
%         if ~leftrightflag, exps = [0 0]; else exps = 0; end
%         return
%     end
% end

exps = [];
if leftrightflag <= 0
    exps = [exps -Rexp(@(x) op(-x),-ends(1),integerflag)];
end
if leftrightflag >= 0
    exps = [exps -Rexp(op,ends(2),integerflag)];
end

warning(dbz_state);

end
% -------------------------------------------------------------------------
function exponent = Rexp(f,loc,BLOWUPSTATE)
% REXP right-exponent
% Given a function f defined on [a,b], finds an exponent
% E such that f*(b-x)^(-E) is bounded at b-eps(b).
% Accepts a third argument BLOWUPSTATE:
% BLOWUPSTATE = 0  cooresponds to BLOWUP OFF
% BLOWUPSTATE = 1  cooresponds to BLOWUP ON in 'poles only' mode
% BLOWUPSTATE = 2  cooresponds to BLOWUP ON in 'branch point' mode 

% Mark Richardson, 2009
if nargin == 1, BLOWUPSTATE=1; end
    switch BLOWUPSTATE 
        case 0
            % blowup off
            exponent=getExp0(f,loc);
        case 1
            % blowup in 'poles only' mode
            exponent=getExp1(f,loc);
        case 2
            % 'experimental' non-integer exponent mode
            exponent=getExp2(f,loc); 
    end            
end

function exponent = getExp0(f,loc)
% currently this outputs 0 as the exponent (as blowup is OFF)
    exponent = 0;
end

function exponent = getExp1(f,loc)
% 'poles only' : integer exponent output
    exponent = 0;
    while blowupB(softenR(f,loc,exponent),loc) && exponent < 101
        exponent = exponent +1;
    end 
    if exponent == 101, exponent = 0; end
end

function exponent = getExp2(f,loc)
% can compute exponents of branch points
    % first pass to getExp1 to obtain upper bound exponent
    b=getExp1(f,loc);
    a=b-1;
    % decimal search    
    tol=0.00000000001;
    count = 0;
    % main loop
    while abs(b-a) > 1.1*tol && count < 101
        numpts = 10;
        points = a:(b-a)/numpts:b;   
        i=1; exponent = points(i);
        % main loop
        while blowupA(softenR(f,loc,exponent),loc) && i<=numpts
            i=i+1;
            exponent=points(i);
        end
        % if blowupA fails, use blowupB
        if i==1
            exponent = getExp1(f,loc);
            return
        else
            a=points(i-1); b=points(i);
        end
        count = count + 1;
    end
end

function divergeA = blowupA(OP,loc)
% One test for blowup - perhaps less robust than test B,
% but more accurate when it works.  This is based on
% a test of monotonicity of the function and its derivative.
% We return 1 if there's a blowup, 0 if not.
    m=12-[0:10]';
    if abs(loc) <= 10*eps(eps)
        epss=loc-m*eps(eps);
    else
        epss=loc-m*eps(loc);
    end  
    vals=abs(OP(epss));
    FDs=diff(vals);
    FDs=FDs(1:end-1);
    monotonic=0;
    for i=2:length(FDs)
        if FDs(i)>FDs(i-1)
            monotonic=monotonic+1;
        end
    end
    if monotonic>=length(FDs)-1        
        divergeA=1;
    else
        divergeA=0;
    end

end

function divergeB = blowupB(OP,loc)
% The other test for blowup - perhaps more robust than test A,
% but less accurate.  This is also based on a monotonicity
% test, but over a scale of O(0.1) rather than O(100*macheps).
% Again we return 1 if there's a blowup, 0 if not.
    n=15;                   
    result=zeros(1,n);
    ratio=zeros(1,n-1);
    test=zeros(1,n-2);
    for i=1:n
        result(i)=OP(loc-10^(-i));
    end
    for i=1:n-1
        ratio(i)=result(i+1)/result(i);
        if i>1                               
            if abs(ratio(i))<1.01     
                test(i-1)=0;                 
            else
                test(i-1)=1;
            end
        end
    end
    total=sum(test);
    if total>10                   
        divergeB=1;
    else
        divergeB=0;
    end    
end

function q = softenR(p,loc,exp) 
% This function takes Op and exponent as inputs and returns the operator
% multiplied by (1+x)^exponent.        
    q = @(x) p(x).*(loc-x).^exp;
end

