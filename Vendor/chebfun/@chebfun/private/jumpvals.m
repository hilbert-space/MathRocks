function vals = jumpvals(funs,ends,ops,pref,scl)
% Updates the values at breakpoints, i.e., the first row of imps.
% If there is a singular point, op is evaluated in order to obtain a 
% value at the breakpoint.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

nfuns = numel(funs);
vals = 0*ends;
if nfuns == 1 && isempty(funs), vals = []; return, end
% Endpoint values
vals(1) = get(funs(1),'lval');
vals(nfuns+1) = get(funs(nfuns),'rval');

if nargin > 2 
        
    if pref.chebkind == 2       
        for k = 2:nfuns
            if funs(k).exps(1) < 0 || isa(ops{k},'double')
                vals(k) = get(funs(k),'lval');
            else
                vals(k) = feval(ops{k},ends(k));
            end
        end
       
    else
        
        % If first kind points were used in construction, make sure
        % representation is continuous.        
        tol = max(10*pref.eps,3e-12)*scl;
        for k = 1:nfuns
            if isa(ops{k},'double')
                vals(k) = get(funs(k),'lval');
            else
                vals(k) = feval(ops{k},ends(k));
            end
        end
        if isa(ops{k},'double')
             vals(k+1) = get(funs(k),'rval');
        else
            vals(k+1) = feval(ops{k},ends(k+1));
        end        
                
        lval = get(funs(1),'lval'); % Check left endpoint of the domain
        if abs(lval-vals(1)) > tol || isnan(vals(1)) % if difference is large, use limit from interior
            vals(1) = lval;
        end
        for k = 2:nfuns
            rval = get(funs(k),'lval');
            lval = get(funs(k-1),'rval');
            if abs(rval-lval) < tol        % is the function continuous?
                if abs(vals(k)-lval) < tol || abs(vals(k)-rval) < tol  % use handle value if close enough
                    funs(k-1).vals(end) =  vals(k);
                    funs(k).vals(1) =  vals(k);
                else
                    if funs(k).n < funs(k-1).n % assume shorter fun is more accurate
                        funs(k-1).vals(end) =  rval;
                    else
                        funs(k).vals(1) = lval;
                    end
                end
            elseif funs(k).exps(1) < 0
                vals(k) = get(funs(k),'lval');
            end
            % If none of the above keep val from function handle            
        end       
        rval =  get(funs(nfuns),'rval'); % Check right endpoint of domain
        if abs(rval-vals(end)) > tol || isnan(vals(end)) % if difference is large, use limit from interior
            vals(end) = rval;
        end
    end
    
else % Function handle is not provided
    for k = 2:nfuns
        vals(k) = get(funs(k),'lval');
    end
end

vals = vals(:).';




% OLD CODE
% if isa(op,'chebfun')
%    op = @(x) feval(op,x);
% end
%
% vals = zeros(size(ends));
% vals(1) = funs(1).vals(1);
% 
% if funs(1).exps(1) < 0, vals(1) = inf;
% elseif funs(1).exps(1) > 0, vals(1) = 0;
% elseif funs(1).exps(2), vals(1) = vals(1).*diff(ends(1:2)).^funs(1).exps(2); end
% 
% if nargin < 3 || isa(op,'double') || isa(op,'fun')
%     for k = 2:numel(funs)
%         vals(k)  = funs(k).vals(1);
%         
%         if funs(k).exps(1) < 0, vals(k) = inf;
%         elseif funs(k).exps(1) > 0, vals(k) = 0;
%         elseif funs(k).exps(2), vals(k) = vals(k).*diff(ends(k:k+1)).^funs(k).exps(2); end
% 
%     end
% else
%     for  k = 2:numel(funs)
%         vals(k)  = op(ends(k));
%         
%         if funs(k).exps(1) < 0, vals(k) = inf;
%         elseif funs(k).exps(1) > 0, vals(k) = 0;
%         elseif funs(k).exps(2), vals(k) = vals(k).*diff(ends(k:k+1)).^funs(k).exps(2); end
%     end
% end
% 
% vals(end) = funs(end).vals(end);
% 
% if funs(end).exps(2) < 0, vals(end) = inf;
% elseif funs(end).exps(2) > 0, vals(end) = 0;
% elseif funs(end).exps(1), vals(end) = vals(end).*diff(ends(end-1:end)).^funs(end).exps(1); end

