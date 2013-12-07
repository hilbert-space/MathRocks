function g = ctor( g , op , ends , varargin )
% CTOR  fun2 constructor
% The classic constructor for fun2. This is where almost every
% function gets approximated.  We adaptively decide the rank and
% polynomial degrees of the approximant. First the rank is decided using
% iterative Gaussian elimination, and then the polynomials degrees are
% decided. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

ni = nargin;
if ni == 0, return; end;  % return empty fun2.
if ni == 1
    if( isa(op,'fun2') ), g = op; end;
end
if( ni > 2 && iscell(ends) ) , ends = ends{:}; end % deref cell.
% Default Preferences
pref2 = chebfun2pref;
pref2.rank=0;                  % Adaptive case by default
vectorize = 0 ;
vscl = [];
if( ni > 3 )
    if(isa(varargin{1},'struct'))
        % Preferences passed
        pref2 = varargin{1};
        if ~isfield(varargin{1},'rank')
            pref2.rank=0;                     % Adaptive case
        end
    elseif (any(strcmpi(varargin{1},'vectorize')) || any(strcmpi(varargin{1},'vectorise')))
        vectorize = 1;
    elseif (strcmpi(varargin{1},'scl'))
        % has vertical scale been overloaded.
        vscl = 1;
    elseif(~isempty(varargin{1}))
        % Preferences not passed, just rank or corners.
        if(length(varargin{1}) == 2)  % then its corners.
            % Take as second half of domain.
            ends = [ ends varargin{1}];
        elseif( ~iscell(varargin{1}) && ~strcmpi(varargin{1},'equi'))
            pref2.rank=varargin{1};              % Non-adaptive case
        elseif( iscell(varargin{1}) )
            ends = [ ends varargin{1}{1}];
        end
    end
end
if ( ni > 4 )  % ignore all the other trailing stuff for now.
    if( ~isempty(varargin{2}) )
        % Preferences not passed, its both rank and corners.
        % Take as second half of domain.
        ends = [ends varargin{1}];
        % Check to see rank.
        pref2.rank=varargin{2};
    end
end

if(nargin < 3), ends = [pref2.xdom pref2.ydom]; end
% Switch NaNs (for adaptive case) to zeros.
if isnan(pref2.rank), pref2.rank=0; end

%% Deal with endpoints and maps
if ~isnumeric(ends)
    % A map may optionally be passed in the second arg.
    g.map = linear2D([-1,1,-1,1]);
elseif(length(ends) == 4)
    g.map = linear2D(ends); % rectangle defined as [a b c d];
elseif(length(ends) == 2 )
    warning('FUN2:constructor:domain','Only given domain in x-direction - taken the y-direction from preferences');
    ends = [ ends pref2.ydom];  %Complete domain description.
    g.map = linear2D(ends);    % rectangle defined as [a b c d];
end

%% Deal with input op type
switch class(op)
    case 'fun2'      % Returns the same fun
        g = op;
        if ni > 2
            warning('FUN2:constructor:input',['Generating fun2 from the first' ...
                ' input argument. Other arguments are not used.'])
        end
        return
    case 'struct'
        % It's a struct containing information to make a fun2. So make one.
        g.U=op.U;g.PivPos=op.PivPos;
        g.rank=op.rank;g.scl=op.scl;
        g.C=op.C;g.R=op.R;g.map=op.map;
        
        return;
    case 'double'   % Assigns value to the Chebyshev points
        tol=pref2.eps;
        vscl = max(max(op(:)),1);
        
        if any(size(op) == 1)
            if all(size(op) == 1)
                % then op is just a scalar.
                if isempty(varargin)
                    g = fun2(op*ones(2),ends);return;
                else
                    g = fun2(op*ones(2),ends,varargin);return;
                end
            else
                error('FUN2:constructor:double','Vector inputs are not allowed.')
            end
        end
        if ni > 2 && pref2.rank
            [PivotValue,PivotPos,Rows,Cols,ignored] = nonadapt_ACA(op,pref2.rank);
        else
            [PivotValue,PivotPos,Rows,Cols,ignored] = CompleteACA(op,0);
        end
        
        % Do a simple truncation of the small Pivotvalues.
        idx = find(abs(PivotValue)>10*tol*vscl,1,'last');
        if isempty(idx)  % check for zero function.
            idx = 1;
        end
        PivotValue = PivotValue(1:idx);
        PivotPos = PivotPos(1:idx,:);
        Cols = Cols(:,1:idx);
        Rows = Rows(1:idx,:);
        
        % If we are given equispaced data, if so transform to Chebyshev grid
        if (ni > 3 && any(strcmpi(varargin{1}, 'equi')))
            % Find near optimal d and necessary length to represent the columns/rows
            linComb = sin((1:idx));
            ColComb = Cols*linComb'; 
            RowComb = linComb*Rows;
            [ColCombFqi, ColDOpt] = funqui(ColComb, ends(3:4)); % fun2/private/funqui.m
            [RowCombFqi, RowDOpt] = funqui(RowComb', ends(1:2));
            ColCombFqi = chebfun(ColCombFqi, ends(3:4));
            RowCombFqi = chebfun(RowCombFqi, ends(1:2));
            y = chebpts(length(ColCombFqi), ends(3:4));
            x = chebpts(length(RowCombFqi), ends(1:2));
            ColsEqui = Cols; RowsEqui = Rows;
            Cols = zeros(length(ColCombFqi),idx);
            Rows = zeros(idx,length(RowCombFqi));
            for k = 1:idx
                ColFqi = funqui(ColsEqui(:,k), ends(3:4), ColDOpt);
                RowFqi = funqui(RowsEqui(k,:).', ends(1:2), RowDOpt);
                Cols(:,k) = ColFqi(y);
                Rows(k,:) = RowFqi(x).';
            end
        end
        
        [n,m] = size(op);
        x = chebpts(m,ends(1:2)); y = chebpts(n,ends(3:4));
        %x = flipud(x); y = flipud(y);
        
        %         Cols = flipud(Cols);
        %yy=flipud(yy); % An entry in first row of a column should be at y=1 not y=-1.
        if norm(op,inf) < 5*eps
            PivPos = [mean(ends(1:2)) mean(ends(3:4))];
        else
            %             PivPos = [xx(1,PivotPos(:,2)); yy(PivotPos(:,1),1).'].';
            PivPos = [x(PivotPos(:,2)).'; y(PivotPos(:,1)).'].';
        end
        
        if pref2.mode
            Rows = transpose(chebfun(Rows.',ends(1:2))); Cols = chebfun(Cols,ends(3:4));
        end
        % Construct a FUN2
        g.U = PivotValue;
        g.PivPos = PivPos; % Store pivot positions for plotting.
        if length(PivotValue) == 1 && PivotValue(1) == 0
            g.rank = 0;
        else
            g.rank = length(PivotValue);
        end
        
        g.scl = abs(PivotValue(1));
        %if ~isempty(vscl), g.scl = vscl; end % scl has been overloaded.
        g.C = Cols;
        g.R = Rows;
        return
    case 'char'
        % Convert string input to anonymous function.
        op = str2op(op);
    case 'function_handle'
        % Check that the operator then make it complex.
        if nargin(op) == 1
            op = @(x,y) op(x+1i*y);
        end
        % Quick check to see if we have a op = @(x,y) 1, or something like that.
        m1 = mean(ends(1:2)); m2 = mean(ends(3:4));
        E = ones(2,2);
        if (vectorize == 0) && all( size(op(m1*E,m2*E)) == [1 1])
            % sizes are not going to match so let's try with the vectorize
            % flag on.
            if ~( numel(op(m1*E,m2*E))==1 && norm(op(m1*E,m2*E))==0 )
                
                
                warning('FUN2:CTOR:VECTORIZE','Function did not correctly evaluate on an array. Turning on the ''vectorize'' flag. Did you intend this? Use the ''vectorize'' flag in the chebfun2 constructor call to avoid this warning message.');
                g = fun2(op,ends,'vectorize');
                return;
            end
        elseif ( (vectorize == 0) && isempty(vscl) )
            % check for cases: @(x,y) x*y, and @(x,y) x*y'
            [xx yy]=meshgrid(ends(1:2),ends(3:4));
            A = op(xx,yy); B = zeros(2);
            for j = 1:2
                for k = 1:2
                    B(j,k) = op(ends(j),ends(2+k));
                end
            end
            if any(any( abs(A - B.') > min(1000*chebfun2pref('eps'),1e-4)))
                warning('FUN2:CTOR:VECTORIZE','Function did not correctly evaluate on an array. Turning on the ''vectorize'' flag. Did you intend this? Use the ''vectorize'' flag in the chebfun2 constructor call to avoid this warning message.');
                g = fun2(op,ends,'vectorize');
                return;
            end
        end
end

% Call constructor
if pref2.rank
    
    if isempty(varargin)
        varargin = {};
    end
    g = nonadaptive_ctor(g,op,ends,vectorize, varargin{:});
    return;
    %     error('FUN2:constructor:pref','There is no non-adaptive constructor.');
    
else
    %% Adaptive case.
    % Do ACA while making sure the slices are resolved.
    
    % Extract out properties from structures.
    tol=pref2.eps; maxrank = pref2.maxrank;
    maxdegree = pref2.maxslice;
    hscale = max(max(abs(ends)),1); % don't ask for more than 16 digits.
    tol = tol * hscale;
    rk = floor(pref2.minsample/2);
    spotcheck = 1;
    while spotcheck
        imunhappy = 1;  % If unhappy, selected pivots were not good enough.
        while imunhappy && rk < maxrank
            rk = 2^(floor(log2(rk))+1)+1;  % discretise on powers of 2, clustering is important.
            [xx,yy]=chebpts2(rk,rk,ends);
            vals = evaluate(op,xx,yy,vectorize);             % Matrix of values at cheb2 pts.
            scl = max(abs(vals(:))); %scl = max(1,scl);
            if ~isempty(vscl), scl = max(scl,1); end % scale has been overloaded.
            if isinf(scl)
                error('FUN2:CTOR','Function returned INF when evaluated');
            end
            if any(any(isnan(vals)))
                error('FUN2:CTOR','Function returned NaN when evaluated');
            end
            [PivotValue,PivotPos,Rows,Cols,ifail] = CompleteACA(vals,tol);
            strike = 1;
            while ifail && rk<=maxrank && strike < 3
                rk=2^(floor(log2(rk))+1)+1;                % Double the sampling
                [xx,yy]=chebpts2(rk,rk,ends);
                vals = evaluate(op,xx,yy,vectorize);                           % Resample on denser grid.
                [PivotValue,PivotPos,Rows,Cols,ifail] = CompleteACA(vals,tol);
                if abs(PivotValue(1))<1e4*scl*tol, strike = strike + 1; end %If the function is 0+noise then stop after three strikes.
            end
            if rk >= maxrank
                error('FUN2:CTOR','Not a low-rank function.');
            end
            
            if size(Cols,1)>1 && size(Rows,2)>1
                % See if the slices are resolved.
                newCols = mysimplify(Cols,hscale,scl,tol);
                if size(newCols,1) < size(Cols,1),ResolvedCols=1;else ResolvedCols=0;end
                lenc = 2.^ceil(log2(size(newCols,1))) + 1;
                lenc = max(lenc,length(PivotValue));
                
                newRows = mysimplify(Rows.',hscale,scl,tol).';
                if size(newRows,2) < size(Rows,2),ResolvedRows=1;else ResolvedRows=0;end
                lenr = 2.^ceil(log2(size(newRows,2))) + 1;
                lenr = max(lenr,length(PivotValue));
                
                Cols = wrap(Cols,lenc);
                Rows = wrap(Rows.',lenr).';
                
                % truncate the rank if we can
                
                ResolvedSlices = ResolvedRows & ResolvedCols;
                if strike >= 3
                    ResolvedSlices =1;
                    Cols = 0; Rows = 0; PivotValue=0;
                end   %If the function is 0+noise then pass along as resolved.
            end
            
            
            
            if length(PivotValue)==1 && PivotValue==0
                PivPos=[0 0]; ResolvedSlices=1;
            else
                PivPos = [xx(1,PivotPos(:,2)); yy(PivotPos(:,1),1).'].'; PP=PivotPos;
            end
            n=rk; m=rk;
            % If unresolved then perform ACA on selected slices.
            while ~ResolvedSlices
                if ~ResolvedCols
                    n=2^(floor(log2(n))+1)+1;
                    [xx yy] = meshgrid(PivPos(:,1),chebpts(n,ends(3:4)));
                    Cols = evaluate(op,xx,yy,vectorize);
                    oddn = 1:2:n; PP(:,1) = oddn(PP(:,1)); % find location of pivots on new grid.
                else
                    [xx yy] = meshgrid(PivPos(:,1),chebpts(n,ends(3:4)));
                    Cols = evaluate(op,xx,yy,vectorize);
                end
                if ~ResolvedRows
                    m =2^(floor(log2(m))+1)+1;
                    [xx yy] = meshgrid(chebpts(m,ends(1:2)),PivPos(:,2));
                    Rows = evaluate(op,xx,yy,vectorize);
                    oddm = 1:2:m; PP(:,2) = oddm(PP(:,2)); % find location of pivots on new grid.
                else
                    [xx yy] = meshgrid(chebpts(m,ends(1:2)),PivPos(:,2));
                    Rows = evaluate(op,xx,yy,vectorize);
                end
                
                nn = numel(PivotValue);
                % ACA on selected Pivots.
                for kk=1:nn-1
                    selx = PP(kk+1:nn,1); sely = PP(kk+1:nn,2);
                    Cols(:,kk+1:end) = Cols(:,kk+1:end) - Cols(:,kk)*(Rows(kk,sely)./PivotValue(kk));
                    Rows(kk+1:end,:) = Rows(kk+1:end,:) - Cols(selx,kk)*(Rows(kk,:)./PivotValue(kk));
                end
                
                % Are the columns and rows resolved now?
                if ~ResolvedCols
                    newCols = mysimplify(Cols,hscale,scl,tol);
                    if size(newCols,1) < size(Cols,1)
                        ResolvedCols=1;
                    end
                end
                if ~ResolvedRows
                    newRows = mysimplify(Rows.',hscale,scl,tol).';
                    if size(newRows,2) < size(Rows,2)
                        ResolvedRows=1;
                    end
                end
                ResolvedSlices = ResolvedRows & ResolvedCols;
                if max(m,n) >= maxdegree  % max number of degrees allows.
                    error('FUN2:CTOR','Unresolved with maximum Chebfun length: %u.',maxdegree);
                end
                
                
                
            end
            if ResolvedSlices, imunhappy = 0; end % Pivots locations are probably ok.
            
            
            % check the first three pivots are at least okay. Though a rank
            % 1 function doesn't need this check (almost any nonzero pivot location
            % will do).
            if ( length( PivotValue ) > 1 )
                for jj = 1:min(3,length(PivotValue))
                    if max(max(abs(Cols(:,jj))),max(abs(Rows(jj,:)))) - abs(PivotValue(jj)) > hscale*scl*1e-2;
                        imunhappy = 1; break
                    end
                end
            end
        end
        % Simplify to any length:
        if norm(Cols)~=0 && size(Cols,1)>2  % in case we were given the zero function.
            Cols = mysimplify(Cols,hscale,scl,tol);
        end
        if norm(Rows)~=0 && size(Rows,2)>2
            Rows = mysimplify(Rows.',hscale,scl,tol).';
        end
        
        
        % For some reason, on some computers simplify is giving back a
        % scalar zero.  In which case the function is numerically zero. 
        % Artifically set the columns and rows to zero.  
        if norm(Cols) == 0 
            Cols = 0; Rows = 0; PivotValue = 0; 
            PivPos=[0 0]; ResolvedSlices=1;
        end
        
        if norm(Rows) == 0 
            Cols = 0; Rows = 0; PivotValue = 0; 
            PivPos=[0 0]; ResolvedSlices=1;
        end
        
        % Now slices and columns are resolved make chebfuns.
        if pref2.mode
            Rows = transpose(chebfun(Rows.',ends(1:2))); Cols = chebfun(Cols,ends(3:4));
        end
        
        % Construct a FUN2
        g.U = PivotValue;
        g.PivPos = PivPos; % Store pivot positions for plotting.
        % rank is number of pivots unless its the zero function.
        if length(PivotValue) == 1 && PivotValue(1) == 0
            g.rank = 0;
        else
            g.rank = length(PivotValue);
        end
        
        %         g.scl = abs(PivotValue(1));
        % The scale may be wrong so we should update with the sampled column and rows as well.
        g.scl = max([max(abs(Cols(:,1))),max(abs(Rows(1,:))),abs(PivotValue(1))]);
        g.C = Cols;
        g.R = Rows;  % store as rows and not columns.
        
        % evaluate at an arbitary point in the domain, to exclude Chebyshev
        % function etc.
        r = 0.029220277562146; s = 0.237283579771521;
        r = (ends(2)+ends(1))/2 + r*(ends(2)-ends(1));
        s = (ends(4)+ends(3))/2 + s*(ends(4)-ends(3));
        if (abs(op(r,s) - feval(g,r,s)) <= 1e5*scl*pref2.eps)
            spotcheck=0;
        end
        %         spotcheck=0;
    end
    
end
end

function vals = evaluate(op,xx,yy,flag)
if flag
    vals = zeros(size(yy,1),size(xx,2));
    for jj = 1:size(yy,1)
        for kk = 1:size(xx,2)
            vals(jj,kk) = op(xx(1,kk),yy(jj,1));
        end
    end
else
    vals = op(xx,yy);              % Matrix of values at cheb2 pts.
end
end

function op = str2op(op)
% OP = STR2OP(OP), finds the dependent variables in a string and returns
% an op handle than can be evaluated.
depvar = symvar(op);
if numel(depvar) > 2,
    error('FUN2:fun2:depvars',...
        'Too many dependent variables in string input.');
end
if numel(depvar) == 1,
    warning('FUN2:fun2:depvars',...
        'Not a bivariate function handle.');  % exclude the case @(x) for now..
    
    % Not sure if this should be a warning or not.
    
end
op = eval(['@(' depvar{1} ',' depvar{2} ')' op]);
end


function C = wrap(C,n)
% Aliase back for accuracy.

%if n < 9, n = 9; end  % no need to go down too low.

% Wrap, don't just truncate.
if n < size(C,1)
    C = chebfft(C);
    nn = 2*n - 2;
    for j=n+1:size(C,1)
        k = abs( mod( j+n-3 , nn ) - n + 2 ) + 1;
        C(k,:) = C(k,:) + C(j,:);
    end
    C = C(end-n+1:end,:);
    C = chebifft(C);
end


end