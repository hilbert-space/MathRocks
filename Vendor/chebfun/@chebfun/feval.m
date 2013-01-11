function [Fx jumpInfoOut] = feval(F,x,varargin)
% FEVAL   Evaluate a chebfun at one or more points.
% 
% FEVAL(F,X) evaluates the chebfun F at the point(s) in X.
% FEVAL(F,X,'LEFT') or FEVAL(F,X,'RIGHT') when the chebfun F has a jump
% determines whether to return the left or right limit values. For example,
% if
%  x = chebfun('x',[-1 1]);
%  s = sign(x);
% then
%  feval(s,0)  % returns 0,
%  feval(s,0,'left')  % returns -1,
%  feval(s,0,'right') % returns 1.
%
% See also chebfun/subsref.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

persistent jumpInfo

% Because chebfuns are superior to function_handle, this call can result
% when f is function_handle and x is chebfun. In that case, revert to the
% built-in behavior.
if isa(F,'function_handle')
    Fx = F(x,varargin{:});
    return
end  

lr = '';
forceval = 0;
Fx = [];

%%
% This block deals with returning jump information from bc evaluations.
if ~isempty(F) && F(1).funreturn && nargin > 2 && varargin{1}(1) ~= 'f'
    for k = 1:numel(F)
        FkJ = F(k).jacobian; % Use AD to find parentID & difforder
        if ~isempty(FkJ)
            if FkJ.depth > 2 || ~strcmp(FkJ.parent,'diff')
                error('CHEBFUN:feval:jumplocfail',...
                    'Invalid jump conditions. (See ''help chebop'')');
            end
            ws = FkJ.workspace;
            ID = ws{1}.ID; 
            order = ws{2}; % There is a parent
        else
            ID = F(k).ID; order = 0;               % This is a base var
        end
        ID = repmat(ID,1,length(x));
        order = repmat(order,1,length(x));
        jumpInfo = [jumpInfo struct('loc',x,'ID',ID,'Ord',order)]; %#ok<AGROW>
    end
end
jumpInfoOut = jumpInfo;
if nargin > 2 && strcmp(varargin{1},'reset');
    jumpInfo = [];
    return
end

%%

% If F or x are empty, there's nothing to do. (Fx defined above)
if isempty(F) || isempty(x), return, end

% Quasimatrix?
nchebs = numel(F);

% Support for feval(f,'left') and feval(f,'end'), etc.
if ischar(x)
    dom = domain(F);
    if any(strcmpi(x,{'left','start','-'}))
        x = dom(1);
    elseif any(strcmpi(x,{'right','end','+'}))
        x = dom(end);
    else
        error('CHEBFUN:feval:strinput','Unknown input argument "%s".',x);
    end
end
    
% Deal with feval(f,x,'left') and feval(f,x,'right')
if nargin > 2
    lr = varargin{1};
    parse = strcmpi(lr,{'left','right','','force','-','+'});
    if ~any(parse);
        if ischar(lr)
            error('CHEBFUN:feval:leftrightchar',...
                'Unknown input argument "%s".',lr);
        else
            error('CHEBFUN:feval:leftright','Unknown input argument.');
        end
    end
    % We deal with this by reassigning imps to be left/right values.
    if parse(1) || parse(5)% left
        for k = 1:nchebs
            F(k).imps(2:end,:) = []; % Level 2 imps are not needed here
            nfuns = F(k).nfuns;
            for j = 1:nfuns
                F(k).imps(1,j+1) = get(F(k).funs(j),'rval');
            end
        end
    elseif parse(2) || parse(6) % right
        for k = 1:nchebs
            F(k).imps(2:end,:) = []; % Level 2 imps are not needed here
            nfuns = F(k).nfuns;
            for j = 1:nfuns
                F(k).imps(1,j) = get(F(k).funs(j),'lval');
            end
        end
    elseif parse(4) % force value evaluation
        forceval = 1;
        lr = '';
    end
end

% Deal with quasimatrices.
if nchebs > 1,
    x = x(:); lenx = length(x);
    if ~forceval && get(F,'funreturn')
        Fx = chebconst;
    else
        Fx = zeros(lenx,nchebs);
    end
    if F(1).trans
        Fx = Fx.';
        for k = 1:nchebs
            Fx(k,:) = fevalcolumn(F(k),transpose(x),lr,forceval);
        end
    else
        for k = 1:nchebs
            Fx(:,k) = fevalcolumn(F(k),x,lr,forceval);
        end
    end
else
    Fx = fevalcolumn(F,x,lr,forceval);
end

% Evaluate a single chebfun
% ------------------------------------------
function fx = fevalcolumn(f,x,lr,forceval)

fx = zeros(size(x));

funs = f.funs;
ends = f.ends;

I = x < ends(1);
if any(I(:))
    fx(I) =  feval(funs(1),x(I));
end
for i = 1:f.nfuns
    I = x >= ends(i) & x < ends(i+1);
    if any(I(:))
        fx(I) = feval(funs(i),x(I));
    end
end
I = x >= ends(f.nfuns+1);
if any(I(:))
    fx(I) =  feval(funs(f.nfuns),x(I));
end

% DEALING WITH IMPS
% If the evaluation point corresponds to a breakpoint, we get the value
% from imps. If there is only one row, the value is given by the corresponding
% entry in that row. If the second row is nonzero the value is -inf or
% inf corresponding to the sign of the entry in the 2nd row. If the entry
% in the corresponding 3rd or higher rows is nonzero, we return NaN.

% Only one row
if (size(f.imps,1) == 1 || ~any(any(f.imps(2:end,:)))) %&& any(f.imps(1,:))
    % RodP and NickH used this to fix the problem
    % when repeated values of x intersect with ends.
    if f.nfuns < 10
        for k = 1:f.nfuns+1
            fx( x==ends(k) ) = f.imps(1,k);
        end
    else
        [ignored,ignored,pos] = intersect(x,ends); %#ok<ASGLU>
        for k = 1:length(pos)
            fx( x == ends(pos(k)) ) = f.imps(1,pos(k));
        end
    end
    
    % NickH fixed this also for the case when there imps has two rows.
elseif size(f.imps,1) > 1 && any(any(f.imps(2:end,:)))
    for j = 1:size(x,2)
        xj = x(:,j);
        [ignored,ignored,pos] = intersect(xj,ends); %#ok<ASGLU>
        for k = 1:length(pos)
            % We take the sign of the largest degree impulse?
            [I ignored sgn] = find(f.imps(2:end,pos(k)),1,'last'); %#ok<ASGLU>
            if isempty(I)
                fx( xj == ends(pos(k)) , j ) = f.imps(1,pos(k));
            elseif I == 1
                if sgn > 0
                    fx( xj == ends(pos(k)) , j ) = inf;
                else
                    fx( xj == ends(pos(k)) , j ) = -inf;
                end
            else
                fx( xj == ends(pos(k)) , j ) = NaN;
            end
        end
    end
    
end

if ~forceval && get(f,'funreturn')
  % If length(x)>1, we will use a column quasimatrix, regardless of the
  % shape of x. This is consistent with linop interpretation of
  % quasimatrices.
  funx = chebconst;
  for j = 1:numel(fx)
    newfun = chebconst(fx(j),domain(f)); 
    newfun.jacobian = anon(['[der1,nonConst1] = diff(f,u,''linop''); ',...
        'der = feval(domain(f),x,lr)*der1; nonConst = nonConst1;'],...
        {'f','x','lr'},{f,x(j),lr},1,'feval');
    funx(j) = newfun;
  end
  fx = funx;
end




